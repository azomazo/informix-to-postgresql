require 'optparse'
require 'rdoc/usage'
require 'ostruct'
require 'date'
require 'lib/reform_unload'
require 'lib/sql_parser'
require 'pathname'

class Informix2Postgres
  VERSION = '0.0.1'

  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin

    # set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.quiet = false
    @options.reform_unload = true
  end

  def run
    if parsed_options? and arguments_valid?
      puts "Start at #{DateTime.now} \n\n" if @options.verbose

      if @options.verbose
        output_options
      end

      process_arguments
      process_command

      puts "\nFinished at #{DateTime.now}" if @options.verbose
    else
      output_usage
    end
  end

  protected
  def parsed_options?
    # Specify Options
    opts = OptionParser.new
    opts.on('-v', '--version')          { output_version ; exit 0 }
    opts.on('-h', '--help')             { output_help }
    opts.on('-V', '--verbose')          { @options.verbose = true }
    opts.on('-q', '--quiet')            { @options.quiet = true }
    opts.on('-i', '--informix-backup DIR', 'Informix backup dir') do |dir| 
      @options.informix_backup = dir
    end
    opts.on('-f', '--from-code ENCODING', 'File encoding by Informix backup') do |encoding|
      @options.informix_encoding = encoding
    end
    opts.on('-t', '--to-code ENCODING', 'Output Files encoding') do |encoding|
      @options.output_encoding = encoding
    end
    opts.on('-o', '--output-dir DIR', 'Out put dir') do |dir|
      @options.output_dir = dir
    end
    opts.on('-p', '--parse-sql')        { @options.reform_unload = false }     

    opts.parse!(@arguments) rescue return false

    process_options
    true
  end

  def process_options
    @options.verbose = false if @options.quiet
  end

  def output_options
    puts "Options:\n"

    @options.marhal_dump.each do |name, val|
      puts "  #{name} = #{val}"
    end
  end

  def arguments_valid?
    true
  end

  def process_arguments
    output_directory if @options.output_dir != nil
  end

  def output_directory
    p = Pathname.new(@options.output_dir)
    p.mkdir if !p.exist?
  end

  def output_help
    output_version
    RDoc::usage()
  end
  
  def output_usage
    RDoc::usage('Usage')
  end

  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end

  def process_command
    if @options.reform_unload
      reform = ReformUnload.new(@options)
      reform.reform
    end

    parser = SQLParser.new(@options)
    parser.parse
    #process_standart_input
  end

  def process_standart_input
    input = @stdin.read
  end
end
