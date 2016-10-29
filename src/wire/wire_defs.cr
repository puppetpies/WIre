module Wire
  # Connection error / banners
  CONNERR = ">> Connection error"
  CONNBANNER = ">> Connected to database on"
  
  @@configfile = "config.json"

  # Dummy DB Driver for case else
  class DummyDriver
    def initialize; end
    def query(text); true; end
  end
  
  # Database functions
  def self.ip(schema : String, guid : String, tbl : String, ip_dst : String, ip_hlen : Number, ip_id : Number, ip_len : Number, ip_proto : Number, ip_src : String, ip_sum : Number, ip_tos : Number, ip_ttl : Number, ip_ver : Number)
    io = "INSERT INTO #{schema}.#{tbl} "
    io += "(guid, recv_date, recv_time, ip_dst, ip_hlen, ip_id, ip_len, ip_proto, ip_src, ip_sum, ip_tos, ip_ttl, ip_ver) "
    io += "VALUES ("
    io += "'#{guid}', "
    io += "NOW(), "
    io += "NOW(), "
    io += "'#{ip_dst}',"
    io += "#{ip_hlen},"
    io += "#{ip_id},"
    io += "#{ip_len},"
    io += "#{ip_proto},"
    io += "'#{ip_src}',"
    io += "#{ip_sum},"
    io += "#{ip_tos},"
    io += "#{ip_ttl},"
    io += "#{ip_ver});"
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

  # Tools / Config
  def self.check_permission?
    perm = %x(id -u)[0..0].to_i
    unless perm == 0
      return false
    else
      return true
    end
  end
  
  def self.dbbanner(host, port, username)
    puts "#{CONNBANNER} #{host}:#{port} as #{username}".colorize(:yellow)
  end
  
  def self.home?
    home = "#{ENV["HOME"]}/.#{self.name}"
    unless Dir.exists?("#{home}")
      Dir.mkdir("#{home}")
    else
      return home
    end
    return home
  end
  
  def self.load_config
    home = self.home?
    json_data = ""
    if File.exists?("#{home}/#{@@configfile}")
      File.open("#{home}/#{@@configfile}") do |n|
        n.each_line {|l|
          json_data += "#{l}"
        }
      end
    else
      abort "config.json required under #{home} see examples/"
    end
    return json_data
  end

  # Display modes
  def self.display(src : String, dst : String, tcp_ack : Bool, tcp_fin : Bool, tcp_syn : Bool, tcp_rst : Bool, tcp_push : Bool, tcp_urg : Bool, tcp_doff : Int32, tcp_hlen : Int32, tcp_seq : UInt32, tcp_sum : UInt16, tcp_win : UInt16, hasdata : Bool)
    io = "#{Time.now.to_s} "
    io += "IP Src: #{src.colorize(:white)} "
    io += "IP Dst: #{dst.colorize(:white)} "
    io += "ACK: #{tcp_ack.colorize(:white)} "
    io += "SYN: #{tcp_syn.colorize(:white)} "
    io += "FIN: #{tcp_fin.colorize(:white)} "
    io += "RST: #{tcp_rst.colorize(:white)} "
    io += "PUSH: #{tcp_push.colorize(:white)} "
    io += "URG: #{tcp_ack.colorize(:white)} "
    io += "Offset: #{tcp_doff.colorize(:white)} "
    io += "Header Length: #{tcp_hlen.colorize(:white)} "
    io += "Sequence Num: #{tcp_seq.colorize(:white)} "
    io += "Checksum: #{tcp_sum.colorize(:white)} "
    io += "Window Size: #{tcp_win.colorize(:white)} "
    io += "Has Data?: #{hasdata} "
  end

  def self.display(name : String, var : String | Bool | Int32)
    print "#{name.camelcase}: ".colorize(:blue)
    print "#{var}\n".colorize(:white)
  end
  
  # PID Functions
  def self.createpid
    File.open("/var/run/wire.pid", "w") {|n|
      n.print("#{Process.pid}")
    }
  end
  
  def self.removepid
    File.delete("/var/run/wire.pid")
  end
  
end
