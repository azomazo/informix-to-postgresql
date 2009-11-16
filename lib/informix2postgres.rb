require 'optparse'
require 'rdoc/usage'
require 'ostruct'
require 'date'

class Informix2Postgres
  VERSION = '0.0.1'

  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin

    # set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.quite = false
  end

  def run
    if parsed_options? and arguments_valid?
      puts "Start at #{DateTime.now} \n\n" if @options.verbose

      output_options if @options.verbose # [Optional]

      process_arguments
      precess_command

      puts "\nFinished at #{DateTime.now}" if @options.verbose
    else
      output_usage
    end
  end

  protected
  def parsed_options?
    # Specify Options
    opts = OptionParser.new
    opts.on('-v', '--version')      { output_version ; exit 0 }
    opts.on('-h', '--help')         { output_help }
    opts.on('-V', '--verbose')      { @options.verbose = true }
    opts.on('-q', '--quite')        { @options.quite = true }

    opts.parse!(@arguments) rescue return false

    process_options
    true
  end

  def process_options
    @options.verbose = false if @options.quite
  end

  def output_options
    puts "Options:\n"

    @options.marhal_dump.each do |name, val|
      puts "  #{name} = #{val}"
    end
  end

  def arguments_valid?
    true if @arguments.length == 1
  end

  def process_arguments
  end

  def output_help
    output_version
#    RDoc::usage()
  end
  
  def output_usage
    # RDoc::usage('usage')
  end

  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end

  def process_command
    #process_standart_input
  end

  def process_standart_input
    input = @stdin.read
  end
end
