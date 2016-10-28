# #######################################################################
#
# Author: Brian Hood
# Name: WIre
# Email: <brianh6854@googlemail.com>                                   #
# 
# Description: Packet Capture in pure Crystal
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
  quiet = false
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
    parser.on("-q", "Quiet") { quiet = true }
    parser.on("-h", "--help", "Show help") { puts parser; exit 0 }
  end
  
  begin
    self.createpid # Create process id
    config_json_data = Wire.load_config # Read the json config of your DB details
    j = Jq.new(config_json_data)
    commit_after = j[".commit_interval"].as_i # How many records before commit
    # conn is a union type of 3 Database drivers MySQL / Postgres & MonetDB
    case j[".driver"].as_s
    when "monetdb"
      # MonetDB
      conn = MonetDB::Client.new
      conn.connect(j[".host"].as_s, j[".username"].as_s, j[".password"].as_s, j[".db"].as_s, j[".port"].as_i)
      conn.setAutocommit(false)
      p conn if verbose
    when "mysql"
      # MySQL
      conn = MySQL.connect(j[".host"].as_s, j[".username"].as_s, j[".password"].as_s, j[".db"].as_s, j[".port"].as_i, j[".socket"].as_s)
      p conn if verbose
    when "postgres"
      # Postgres
      conninfo = PQ::ConnInfo.new(j[".host"].as_s, j[".db"].as_s, j[".username"].as_s, j[".password"].as_s, j[".port"].as_i)
      conn = PG.connect(conninfo)
      p conn if verbose
    else
      # Default MySQL
      conn = MySQL.connect(j[".host"].as_s, j[".username"].as_s, j[".password"].as_s, j[".db"].as_s, j[".port"].as_i, j[".socket"].as_s)
      p conn if verbose
    end
    opts.parse!
    puts banner.colorize(:cyan)
    puts "Starting up!".colorize(:red)
    puts "============\n".colorize(:red)
    display("Filter", filter)
    display("Device", device)
    display("Snaplen", snaplen)
    display("Verbose", verbose) 
    display("Dataonly", dataonly)
    display("Hexdump", hexdump)
    
    unless filemode == true
      cap = Pcap::Capture.open_live(device, snaplen: snaplen, timeout_ms: timeout)
    else
      print " > Pcap File: ".colorize(:blue)
      puts "#{dumpfile}"
      cap = Pcap::Capture.open_offline(dumpfile)
    end

    cap.setfilter(filter)
    pktcount = 0
    glbpktcount = 0
    cap.loop do |pkt|
      next if dataonly && !pkt.tcp_data
      if bodymode
        next if whitespace && pkt.tcp_data.to_s =~ /\A\s*\Z/
        puts "%s: %s" % [pkt.packet_header, pkt.tcp_data.to_s.inspect]
      else
        # Data capture
        sameuuid = SecureRandom.uuid # Needs to be the same for JOIN query
        sql_ip = ip("#{j[".schema"].as_s}", sameuuid, "#{j[".tbl_ippacket"].as_s}", pkt.ip_dst, pkt.ip_hl, pkt.ip_id, pkt.ip_len, pkt.ip_proto, pkt.ip_src, pkt.ip_sum, pkt.ip_tos, pkt.ip_ttl, pkt.ip_v)
        sql_tcp = tcp("#{j[".schema"].as_s}", sameuuid, "#{j[".tbl_tcppacket"].as_s}", pkt.tcp_data_len, pkt.tcp_dst, pkt.tcp_ack?, pkt.tcp_fin?, pkt.tcp_syn?, pkt.tcp_rst?, pkt.tcp_push?, pkt.tcp_urg?, pkt.tcp_doff, pkt.tcp_hlen, pkt.tcp_seq, pkt.tcp_sum, pkt.tcp_src, pkt.tcp_win)
        puts "#{glbpktcount}: IP: #{sql_ip}" if verbose
        puts "#{glbpktcount}: TCP: #{sql_tcp}" if verbose
        conn.query(sql_ip)
        conn.query(sql_tcp)
        case hexdump
        when false
          case pkt.tcp_data.to_s.size
          when 0
            hasdata = false
          else
            hasdata = true
          end
          puts display(pkt.src, pkt.dst, pkt.tcp_ack?, pkt.tcp_fin?, pkt.tcp_syn?, pkt.tcp_rst?, pkt.tcp_push?, pkt.tcp_urg?, pkt.tcp_doff, pkt.tcp_hlen, pkt.tcp_seq, pkt.tcp_sum, pkt.tcp_win, hasdata) unless quiet
          puts "-" * separatorlen unless quiet
          puts pkt.inspect if verbose
        else
          puts "#{pkt.packet_header} #{pkt.src} #{pkt.dst}".colorize(:yellow)
          puts pkt.hexdump
        end
      end
      if commit_after == pktcount
        begin
          conn.query("COMMIT;")
          puts "Commit #{pktcount} !".colorize(:yellow) if verbose
          pktcount = 0
        rescue
          abort "Commit failure".colorize(:red)
        end
      end
      glbpktcount += 1
      pktcount += 1
    end
    at_exit { 
      conn.query("COMMIT;")
      cap.close 
      print "Total Packets: "
      print "#{glbpktcount}".colorize(:white)
      puts ""
      self.removepid # Delete process id file
    }
  rescue err
    STDERR.puts "#{$0}: #{err}" # The Catch all
  end
end
