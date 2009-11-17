require 'pathname'

class SQLParser

  def initialize(options)
    @options = options
  end

  def parse
    is_create_table = false
    is_create_index = false
    create = ""
    table_name = ""
    pkey_name = ""
    unload_file = ""

    file = File.open(@options.informix_backup + "/" + main_filename)
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
          p = Pathname.new(@options.output_dir + "/" + unload_file)
          create += "\nCOPY " + table_name + " FROM \'" + p.realpath + "\' WITH DELIMITER AS \'|\' NULL AS \'\';\n"
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
    
    pg_file = File.new(@options.output_dir + "/" + main_filename, "w+")
    pg_file.puts create
  end

  protected
  def main_filename
    p = Pathname.new(@options.informix_backup)
    p.basename.to_s.scan(/\w+/)[0] + ".sql"
  end
end
