#!/usr/bin/ruby

# Скрипт переделывания файлов выгрузки (*.unl) informix в формат загрузки postgres

require 'find'

WORK_DIR = "../tur.exp/"

current_file = ""

str = ""

Dir.foreach(WORK_DIR) do |path| 
  next if path == "." or path == ".."
  break if path =~ /.pg/
  current_file = WORK_DIR + path
  conv = %x(enconv #{current_file})
  puts "Convertation " + path + " complited"
  if conv != ""
    puts conv
  end

  name = File.basename(current_file)
  
  if name =~ /unl/ and name !=~ /pg/
    file = File.new(current_file)
    out = File.new(current_file + ".pg", "w+")
    file.each do |line|
      line.chomp!
      if line[/.$/] == "|"
        out.puts str == "" ? line.chomp("|") : str.chomp ("|")
        str = ""
      else
        str = str + line
      end
    end
  end
end
