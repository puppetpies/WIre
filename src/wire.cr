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
require "mysql"
require "./wire/*"
require "pcap"
require "json"
require "colorize"
require "option_parser"

module Wire
  class DB
    property? driver : String
    property? host : String
    property? username : String
    property? password : String
    property? schema : String
    property? port : UInt16
    property? conn : MySQL::Connection | MonetDBMAPI::Mapi
    
    def initialize(driver, host, username, password, schema, port)
      @driver = driver
      @host = host
      @username = username
      @password = password
      @schema = schema
      @port = port
      @conn = connect
    end
    
    def connect
      if @driver == "monetdb"
        @conn = MonetDB::ClientJSON.new
        @conn.host = @host
        @conn.username = @username
        @conn.password = @password
        @conn.db = @schema
        @conn.port = @port
        @conn.connect
      elsif @driver == "mysql"
        @conn = MySQL.connect(@host, 
                              @username, 
                              @password, @schema, @port, nil)
      end
    end
    
    def query(sql)
      begin
        @conn.query(sql)
      rescue err
        STDERR.puts "#{$0}: #{err}"
      end
    end
  end
end

module Wire
  filter   = "tcp port 80"
  device   = "lo"
  snaplen  = 1500
  timeout  = 1000
  verbose  = false
  dataonly = false
  bodymode = false
  filemode = false
  dumpfile = ""
  separatorlen = 100
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
    parser.on("-h", "--help", "Show help") { puts parser; exit 0 }
  end

  begin
    config_json_data = Wire.load_config
    j = Jq.new(config_json_data)
    if j[".driver"].as_s == "monetdb"
      conn = MonetDB::ClientJSON.new
      conn.host = j[".host"].as_s
      conn.port = j[".port"].as_i
      conn.username = j[".username"].as_s
      conn.password = j[".password"].as_s
      conn.db = j[".schema"].as_s
      conn.connect
      if conn.is_connected?
        puts " >> Connected to MonetDB on #{j[".host"].as_s}:#{j[".port"].as_i}".colorize(:yellow)
      else
        abort " >> Connection error".colorize(:red)
      end
    elsif j[".driver"].as_s == "mysql"
      conn = MySQL.connect(j[".host"].as_s, 
                           j[".username"].as_s, 
                           j[".password"].as_s, j[".schema"].as_s, j[".port"].as_i, nil)
      if conn
        puts " >> Connected to MySQL on #{j[".host"].as_s}:#{j[".port"].as_i}".colorize(:yellow)
      else
        abort " >> Connection error".colorize(:red)
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
    
    unless filemode == true
      cap = Pcap::Capture.open_live(device, snaplen: snaplen, timeout_ms: timeout)
    else
      puts " > Pcap File: #{dumpfile}".colorize(:blue)
      cap = Pcap::Capture.open_offline(dumpfile)
    end
    at_exit { cap.close }
    cap.setfilter(filter)
    cap.loop do |pkt|
      next if dataonly && !pkt.tcp_data
      if bodymode
        puts "%s: %s" % [pkt.packet_header, pkt.tcp_data.to_s.inspect]
      else
        #puts pkt.to_s
        puts "-" * separatorlen
        puts display(pkt.src, pkt.dst)
        puts "-" * separatorlen
        puts pkt.inspect if verbose
        #puts "-" * separatorlen     if verbose
        #puts pkt.inspect  if verbose
        #puts pkt.hexdump
      end
    end
  rescue err
    STDERR.puts "#{$0}: #{err}"
  end
end
