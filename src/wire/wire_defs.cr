module Wire

  def self.check_permission?
    perm = %x(id -u)[0..0].to_i
    unless perm == 0
      return false
    else
      return true
    end
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
