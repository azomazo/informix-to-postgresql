#!/usr/bin/ruby

# Скрипт для разбора файла дампа informix и перевода в postgres

file = File.open("../tur.exp/tur.sql")
file.each do |line|
  e = line
  if line =~ /create table/
    e["\"informix\"."] = ""
    puts e
  end
end
