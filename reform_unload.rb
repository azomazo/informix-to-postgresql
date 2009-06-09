#!/usr/bin/ruby

# Скрипт переделывания файлов выгрузки (*.unl) informix в формат загрузки postgres

require 'find'

WORK_DIR = "../tur.exp/"

str = ""

Dir.foreach(WORK_DIR) do |path| 
  puts path
  name = File.basename(WORK_DIR + path)
  if name =~ /unl/ and name !=~ /pg/
    file = File.new(WORK_DIR + path)
    out = File.new(WORK_DIR + path + ".pg", "w+")
    file.each do |line|
#      s = line.rindex("|")-1
#      puts s
#      puts line
#      puts line[0..s]
#      if line[0] == "\\"
#        line[0] = ""
#      end
      puts line
      line.chomp!
      if line[/.$/] == "|"
        out.puts str == "" ? line.chomp("|") : str.chomp ("|")
        str = ""
      else
        str = str + line
      end
#      puts line.chomp("|")
#      out.puts line.chomp("|")
    end
  end
end
