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

require "pcap"
require "./wire/*"
require "json"
require "colorize"
require "crystal-monetdb-libmapi"
require "option_parser"

def check_permission?
  perm = %x(id -u)[0..0].to_i
  unless perm == 0
    return false
  else
    return true
  end
end

def display(src : String, dst : String)
  io = "#{Time.now.to_s} "
  io += "Src IP Addr: #{src.colorize(:yellow)} "
  io += "Dst IP Addr: #{dst.colorize(:yellow)} "
end

module Pcap
  class IpHeader
    def inspect(io : IO)
      io << "IpHeader\n"
      io << "  Version         : #{ip_v}  Protocol  : #{ip_proto}\n" % 
      io << "  Header Length   : %d words (%d bytes)\n" % [ip_hl, ip_hl*4]
      io << "  Service Type    : %s\n" % ip_tos
      io << "  Total Length    : %s\n" % ip_len
      io << "  Identification  : %s\n" % ip_id
      io << "  Flags           : #{ip_frag}   TTL : #{ip_ttl}\n"
      io << "  Header Checksum : %s\n" % ip_sum
      io << "  Src IP Addr     : #{src}   Dst IP Addr     : #{dst}\n"
    end
  end
end

module Pcap
  class TcpHeader
    def inspect(io : IO)
      io << "TcpHeader\n"
      io << "  Src Port: #{tcp_src} Dst Port: #{tcp_dst}\n" 
      io << "  Sequence Number     : %s\n" % tcp_seq
      io << "    Data Offset       : %d words (%d bytes)\n" % [tcp_doff, length]
      io << "    Flags             : [%s]\n" % tcp_flags
      io << "      CWR: #{tcp_cwr?} ECE: #{tcp_ece?} URG: #{tcp_urg?} ACK: #{tcp_ack?}\n"
      io << "      PUSH: #{tcp_push?} RST: #{tcp_rst?} SYN: #{tcp_syn?} FIN: #{tcp_fin?}\n" 
    end
  end
end

module Pcap
  class Capture
    def self.open_live(device : String, snaplen : Int32 = DEFAULT_SNAPLEN, promisc : Int32 = DEFAULT_PROMISC, timeout_ms : Int32 = DEFAULT_TIMEOUT_MS)
      errbuf = uninitialized UInt8[LibPcap::PCAP_ERRBUF_SIZE]
      case check_permission?
      when false
        abort "Please execute this appllication as a privileged user !"
        exit
      when true
        pcap_t = LibPcap.pcap_open_live(device, snaplen, promisc, timeout_ms, errbuf)
        if pcap_t.null?
          raise Error.new(String.new(errbuf.to_unsafe))
        end
        netmask = 16776960_u32 # of 0xFFFF00
        return new(pcap_t, netmask)
      else
        exit
      end
    end
  end
end


module Wire
  filter   = "tcp port 80"
  device   = "lo"
  snaplen  = 1500
  timeout  = 1000
  hexdump  = false
  verbose  = false
  dataonly = false
  bodymode = false
  separatorlen = 100
  

  
  opts = OptionParser.new do |parser|
    parser.banner = "WIre version #{VERSION}\n\nUsage: WIre [options]"

    parser.on("-i lo", "Listen on interface") { |i| device = i }
    parser.on("-f 'tcp port 80'", "Pcap filter string. See pcap-filter(7)"  ) { |f| filter = f }
    parser.on("-p 80", "Capture port (overridden by -f)") { |p| filter = "tcp port #{p}" }
    parser.on("-s 1500", "Snapshot length"  ) { |s| snaplen = s.to_i }
    parser.on("-d", "Filter packets where tcp data exists") { dataonly = true }
    parser.on("-b", "Body printing mode"    ) { bodymode = true }
    parser.on("-x", "Show hexdump output"   ) { hexdump  = true }
    parser.on("-v", "Show verbose output"   ) { verbose  = true }
    parser.on("-h", "--help", "Show help"   ) { puts parser; exit 0 }
  end

  begin
    opts.parse!
    
    cap = Pcap::Capture.open_live(device, snaplen: snaplen, timeout_ms: timeout)
    at_exit { cap.close }
    cap.setfilter(filter)

    cap.loop do |pkt|
      next if dataonly && !pkt.tcp_data?

      if bodymode
        #puts "%s: %s" % [pkt.packet_header, pkt.tcp_data.to_s.inspect]
      else
        #puts pkt.to_s
        puts display(pkt.src, pkt.dst)
        puts "-" * separatorlen
        puts pkt.inspect
        #puts "-" * separatorlen     if verbose
        #puts pkt.inspect  if verbose
        #puts pkt.hexdump  if hexdump
      end
    end
  rescue err
    STDERR.puts "#{$0}: #{err}"
  end
end
