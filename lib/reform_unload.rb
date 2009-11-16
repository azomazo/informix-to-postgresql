require 'find'
require 'ftools'
require 'pathname'

class ReformUnload
  def initialize(options)
    @options = options
  end

  def reform
    current_file = ""
    str = ""

    Dir.foreach(@options.informix_backup) do |path| 
      next if path == "." or path == ".."
      current_file = @options.informix_backup + "/" + path
      encoding(current_file)

      name = File.basename(current_file)
  
      if name =~ /unl/ and name !=~ /pg/
        file = File.new(current_file)
        out = File.new(@options.output_dir + "/" + path + ".pg", "w+")
        file.each do |line|
          line.chomp!
          if line[/.$/] == "|"
            out.puts str == "" ? line.chomp("|") : str.chomp("|")
            str = ""
          else
            str = str + line
          end
        end
      end
    end
  end

  protected
  def encoding(filename)
    if @options.informix_encoding == nil or @options.output_encoding == nil
      conv = %x(enconv #{filename})
    else
      File.copy(filename, filename + ".old")
      %x(iconv -f #{@options.informix_encoding} -t #{@options.output_encoding} #{filename + ".old"} > #{filename})
      File.delete(filename + ".old")
    end

    p = Pathname.new(filename)
    puts "Convertation " + p.basename + " compited"
  end 
end
