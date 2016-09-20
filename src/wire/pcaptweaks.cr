# Some tweaks to the output
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

  class Capture
    def self.open_live(device : String, snaplen : Int32 = DEFAULT_SNAPLEN, promisc : Int32 = DEFAULT_PROMISC, timeout_ms : Int32 = DEFAULT_TIMEOUT_MS)
      errbuf = uninitialized UInt8[LibPcap::PCAP_ERRBUF_SIZE]
      case Wire.check_permission?
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
    def setfilter(filter : String, optimize : Int32 = 1)
      # compile first
      bpfprogram = Pointer(LibPcap::BpfProgram).malloc(1_u64)
      checkfilter = LibPcap.pcap_compile(@pcap, bpfprogram, filter, optimize, @netmask)
      if checkfilter == 0
        return LibPcap.pcap_setfilter(@pcap, bpfprogram)
      else
        abort "Please specify a valid pcap filter"
        exit
      end
    end
  end
end
