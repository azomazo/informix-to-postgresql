#!/usr/bin/ruby

# Скрипт для разбора файла дампа informix и перевода в postgres

is_create_table = false
create = ""
file = File.open("../tur.exp/tur.sql")
file.each do |line|
  if line =~ /create table/ and line !~ /--/
    line["\"informix\"."] = ""
    is_create_table = true
    create = line
  elsif line =~ /\([^0-9a-z]/
    if is_create_table
      create += line
    end
  elsif line =~ /[^0-9a-z]\)/
    if is_create_table
      create += ");"
      is_create_table = false
      puts create
      create = ""
    end
  elsif is_create_table
    if line =~ /lvarchar/
      line["lvarchar"] = "varchar"
      create += line
    elsif line =~ /money/
      line["money"] = "numeric"
      create += line
    end
    if line =~ /primary key/
      puts create.size
      create[create.size - 1] = ""
    else
      create += line
    end
  end
end
