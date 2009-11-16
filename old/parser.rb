#!/usr/bin/ruby

# Скрипт для разбора файла дампа informix и перевода в postgres

require 'pathname'

WORK_DIR = "../tur.exp/"

is_create_table = false
is_create_index = false
create = ""
table_name = ""
pkey_name = ""
unload_file = ""

file = File.open(WORK_DIR + "tur.sql")
file.each do |line|
  if line =~ /create table/ and line !~ /--/
    line["\"informix\"."] = ""
    is_create_table = true
    create += line
    table_name = line.split(" ")[2]
  elsif line =~ /unload/
    unload_file = line.scan(/\w+/)[3]+".unl.pg"
  elsif line =~ /create/ and line =~ /index/
    line["\"informix\"."] = ""
    is_create_index = true
  elsif line =~ /\([^0-9a-z]/
    if is_create_table
      create += line
    end
  elsif line =~ /[^0-9a-z]\)/
    if is_create_table
      create += ");"
      if pkey_name != ""
        create += "\nALTER table " + table_name + " add constraint " + table_name + "_pkey primary key (" + pkey_name + ");"
      end
      path = Pathname.new(WORK_DIR + unload_file)
      create += "\nCOPY " + table_name + " FROM \'" + path.realpath + "\' WITH DELIMITER AS \'|\' NULL AS \'\';\n"
      is_create_table = false
    end
  elsif is_create_table
    if line =~ /lvarchar/
      line["lvarchar"] = "varchar"
    elsif line =~ /money/
      line["money"] = "numeric"
    elsif line =~ /datetime year to second/
      line["datetime year to second"] = "timestamp with time zone"
    end
    if line =~ /primary key/
      create.chomp!(",\r\n")
      pkey_name = line.scan(/\w+/)[2]
    else
      create += line
      pkey_name = ""
    end
  end
end

puts create
