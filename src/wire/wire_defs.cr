module Wire

  @@configfile = "config.json"
  
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

  def self.display(src : String, dst : String)
    io = "#{Time.now.to_s} "
    io += "Src IP Addr: #{src.colorize(:yellow)} "
    io += "Dst IP Addr: #{dst.colorize(:yellow)} "
  end

  def self.display_option(name : String, var : String | Bool | Int32)
    print "#{name.camelcase}: ".colorize(:blue)
    print "#{var}\n".colorize(:white)
  end
  
end
