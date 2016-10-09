# #######################################################################
#
# Author: Brian Hood
# Name: WIre
# Email: <brianh6854@googlemail.com>                                   #
# 
# Description: Packet Capture in Crystal
#
#   Thankyou to maiha github.com/maiha for extending my lowevel pcap
#   support for this functionality and accepting a few tweaks.
#   Plus also creating pcap.cr a very nice user library :)
# #######################################################################

require "jq"
require "crystal-monetdb-libmapi"
require "pg"
require "mysql"
require "./wire/*"
require "pcap"
require "json"
require "colorize"
require "option_parser"
require "secure_random"

module Wire
  # Connection error / banners
  CONNERR = ">> Connection error"
  CONNBANNER = ">> Connected to database on"
  
  # Variables to use with Options parser
  filter   = "tcp port 80" # PCAP-FILTER(7) man page for details or TSHARK(1) via wireshark
  device   = "lo" # Interface name default to your local loopback
  snaplen  = 1500 # Default size 1500 like every other capture tool the max is 65535
  timeout  = 1000 # Not implemented in my tool but it limits the number of seconds to capture for ?
  verbose  = false
  dataonly = false
  bodymode = false
  filemode = false
  hexdump = false
  whitespace = false
  dumpfile = "" # Read in a LibPcap created capture file instead of interfaces also works with the database
  separatorlen = 100_u8
  banner = "WIre version #{VERSION}\n\nUsage: WIre [options] | -h for Help\n"
  
  opts = OptionParser.new do |parser|
    parser.banner = banner
    parser.on("-i lo", "Listen on interface") { |i| device = i }
    parser.on("-f 'tcp port 80'", "Pcap filter string. See pcap-filter(7)"  ) { |f| filter = f }
    parser.on("-s 1500", "Snapshot length"  ) { |s| snaplen = s.to_i }
    parser.on("-r file", "Read packets from file") {|d| dumpfile = d; filemode = true }
    parser.on("-d", "Filter packets where tcp data exists") { dataonly = true }
    parser.on("-b", "Body printing mode") { bodymode = true }
    parser.on("-v", "Show verbose output") { verbose  = true }
    parser.on("-w", "Ignore all packets that contain only white spaces") { whitespace = true }
    parser.on("-x", "Hexdump") { hexdump  = true }
    parser.on("-h", "--help", "Show help") { puts parser; exit 0 }
  end
  
  def self.ip(schema : String, guid : String, tbl : String, ip_dst : String, ip_hlen : Number, ip_id : Number, ip_len : Number, ip_proto : Number, ip_src : String, ip_sum : Number, ip_tos : Number, ip_ttl : Number, ip_ver : Number)
    io = "INSERT INTO #{schema}.#{tbl} "
    io += "(guid, recv_date, recv_time, ip_dst, ip_hlen, ip_id, ip_len, ip_proto, ip_src, ip_sum, ip_tos, ip_ttl, ip_ver) "
    io += "VALUES ("
    io += "'#{guid}', "
    io += "NOW(), "
    io += "NOW(), "
    io += "'#{ip_dst}',"
    io += "'#{ip_hlen}',"
    io += "'#{ip_id}',"
    io += "'#{ip_len}',"
    io += "'#{ip_proto}',"
    io += "'#{ip_src}',"
    io += "'#{ip_sum}',"
    io += "'#{ip_tos}',"
    io += "'#{ip_ttl}',"
    io += "'#{ip_ver}');"
  end
  
  def self.tcp(schema : String, guid : String, tbl : String, tcp_data_len : Int32, tcp_dst : UInt16, tcp_ack : Bool, tcp_fin : Bool, tcp_syn : Bool, tcp_rst : Bool, tcp_psh : Bool, tcp_urg : Bool, tcp_off : Int32, tcp_hlen : Int32, tcp_seq : UInt32, tcp_sum : UInt16, tcp_src : UInt16, tcp_win : UInt16)
    io = "INSERT INTO #{schema}.#{tbl} "
    io += "(guid, recv_date, recv_time, tcp_data_len, tcp_dport, tcp_ack, tcp_fin, tcp_syn, tcp_rst, tcp_psh, tcp_urg, tcp_off, tcp_hlen, tcp_seq, tcp_sum, tcp_sport, tcp_win) "
    io += "VALUES ("
    io += "'#{guid}', "
    io += "NOW(), "
    io += "NOW(), "
    io += "#{tcp_data_len},"
    io += "#{tcp_dst},"
    io += "'#{tcp_ack}',"
    io += "'#{tcp_fin}',"
    io += "'#{tcp_syn}',"
    io += "'#{tcp_rst}',"
    io += "'#{tcp_psh}',"
    io += "'#{tcp_urg}',"
    io += "#{tcp_off}, #{tcp_hlen}, #{tcp_seq}, #{tcp_sum}, #{tcp_dst}, #{tcp_win});"
  end

  begin
    config_json_data = Wire.load_config # Read the json config of your DB details
    j = Jq.new(config_json_data)
    case j[".driver"].as_s
    when "monetdb"
      conn = MonetDB::Client.new
      conn.host = j[".host"].as_s
      conn.port = j[".port"].as_i
      conn.username = j[".username"].as_s
      conn.password = j[".password"].as_s
      conn.db = j[".db"].as_s
      conn.connect
      conn.setAutocommit(true)
      p conn
    else
      conn = MonetDB::Client.new
    end
    opts.parse!
    puts banner.colorize(:cyan)
    puts "Starting up!".colorize(:red)
    puts "============\n".colorize(:red)
    display_option("Filter", filter)
    display_option("Device", device)
    display_option("Snaplen", snaplen)
    display_option("Verbose", verbose) 
    display_option("Dataonly", dataonly)
    display_option("Hexdump", hexdump)
    
    unless filemode == true
      cap = Pcap::Capture.open_live(device, snaplen: snaplen, timeout_ms: timeout)
    else
      print " > Pcap File: ".colorize(:blue)
      puts "#{dumpfile}"
      cap = Pcap::Capture.open_offline(dumpfile)
    end
    at_exit { cap.close }
    cap.setfilter(filter)
    pktcount = 0
    cap.loop do |pkt|
      next if dataonly && !pkt.tcp_data
      if bodymode
        next if whitespace && pkt.tcp_data.to_s =~ /\A\s*\Z/
        puts "%s: %s" % [pkt.packet_header, pkt.tcp_data.to_s.inspect]
      else
        # Data capture
        sameuuid = SecureRandom.uuid
        sql_ip = ip("#{j[".schema"].as_s}", sameuuid, "#{j[".tbl_ippacket"].as_s}", pkt.ip_dst, pkt.ip_hl, pkt.ip_id, pkt.ip_len, pkt.ip_proto, pkt.ip_src, pkt.ip_sum, pkt.ip_tos, pkt.ip_ttl, pkt.ip_v)
        sql_tcp = tcp("#{j[".schema"].as_s}", sameuuid, "#{j[".tbl_tcppacket"].as_s}", pkt.tcp_data_len, pkt.tcp_dst, pkt.tcp_ack?, pkt.tcp_fin?, pkt.tcp_syn?, pkt.tcp_rst?, pkt.tcp_push?, pkt.tcp_urg?, pkt.tcp_doff, pkt.tcp_hlen, pkt.tcp_seq, pkt.tcp_sum, pkt.tcp_src, pkt.tcp_win)
        puts "#{pktcount}: IP: #{sql_ip}"
        puts "#{pktcount}: TCP: #{sql_tcp}"
        pktcount += 1
        conn.query(sql_ip)
        conn.query(sql_tcp)
        puts "-" * separatorlen
        case hexdump
        when false
          puts "-" * separatorlen
          puts display(pkt.src, pkt.dst)
          puts "-" * separatorlen
          puts pkt.inspect if verbose
        else
          puts "#{pkt.packet_header} #{pkt.src} #{pkt.dst}".colorize(:yellow)
          puts pkt.hexdump
        end
      end
    end
  rescue err
    STDERR.puts "#{$0}: #{err}" # The Catch all
  end
end
