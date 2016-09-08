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

require "./wire/*"
require "pcap"
require "json"
require "colorize"
require "crystal-monetdb-libmapi"
require "mysql"
require "option_parser"

module Wire

  filter   = "tcp port 80"
  device   = "lo"
  snaplen  = 1500
  timeout  = 1000
  verbose  = false
  dataonly = false
  bodymode = false
  separatorlen = 100
  banner = "WIre version #{VERSION}\n\nUsage: WIre [options] | -h for Help\n"
  
  opts = OptionParser.new do |parser|
    parser.banner = banner
    parser.on("-i lo", "Listen on interface") { |i| device = i }
    parser.on("-f 'tcp port 80'", "Pcap filter string. See pcap-filter(7)"  ) { |f| filter = f }
    parser.on("-s 1500", "Snapshot length"  ) { |s| snaplen = s.to_i }
    parser.on("-d", "Filter packets where tcp data exists") { dataonly = true }
    parser.on("-b", "Body printing mode"    ) { bodymode = true }
    parser.on("-v", "Show verbose output"   ) { verbose  = true }
    parser.on("-h", "--help", "Show help"   ) { puts parser; exit 0 }
  end

  begin
    opts.parse!
    puts banner.colorize(:cyan)
    puts "Starting up!".colorize(:red)
    puts "============\n".colorize(:red)
    display_option("Filter", filter)
    display_option("Device", device)
    display_option("Snaplen", snaplen)
    display_option("Verbose", verbose) 
    display_option("Dataonly", dataonly)
        
    cap = Pcap::Capture.open_live(device, snaplen: snaplen, timeout_ms: timeout)
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
