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
require "crystal-monetdb-libmapi/monetdb_data"
require "pg"
require "mysql"
require "./wire/*"
require "pcap"
require "json"
require "colorize"
require "option_parser"

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
    parser.on("-o dumpfile", "Open pcap dump file") {|d| dumpfile = d; filemode = true }
    parser.on("-d", "Filter packets where tcp data exists") { dataonly = true }
    parser.on("-b", "Body printing mode") { bodymode = true }
    parser.on("-v", "Show verbose output") { verbose  = true }
    parser.on("-w", "We can easily manage White spaces ( diff(1) uses this as ignore all white space)") { whitespace = true }
    parser.on("-x", "Hexdump") { hexdump  = true }
    parser.on("-h", "--help", "Show help") { puts parser; exit 0 }
  end

  begin
    config_json_data = Wire.load_config # Read the json config of your DB details
    j = Jq.new(config_json_data)
    case j[".driver"].as_s
    when "monetdb"
      conn = MonetDB::ClientJSON.new
      conn.host = j[".host"].as_s
      conn.port = j[".port"].as_i
      conn.username = j[".username"].as_s
      conn.password = j[".password"].as_s
      conn.db = j[".schema"].as_s
      conn.connect
      p conn
      if conn.is_connected?
        Wire.dbbanner("#{j[".host"].as_s}", "#{j[".port"].as_i}", "#{j[".username"].as_s}")
      else
        abort CONNERR.colorize(:red)
      end
    when "mysql"
      conn = MySQL.connect(j[".host"].as_s, 
                           j[".username"].as_s, 
                           j[".password"].as_s, j[".schema"].as_s, j[".port"].as_i, nil)
      p conn 
      if conn
        Wire.dbbanner("#{j[".host"].as_s}", "#{j[".port"].as_i}", "#{j[".username"].as_s}")
      else
        abort CONNERR.colorize(:red)
      end
    else
      false
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
    cap.loop do |pkt|
      next if dataonly && !pkt.tcp_data
      if bodymode
        next if whitespace && pkt.tcp_data.to_s =~ /\A\s*\Z/
        puts "%s: %s" % [pkt.packet_header, pkt.tcp_data.to_s.inspect]
      else
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
