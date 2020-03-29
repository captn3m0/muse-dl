require "option_parser"
require "dir"

module Muse::Dl
  class Parser
    @bookmarks = true
    @tmp : String
    @cleanup = true
    @output = DEFAULT_FILE_NAME
    @url = "INVALID_URL"

    DEFAULT_FILE_NAME = "tempfilename.pdf"

    getter :bookmarks, :tmp, :cleanup, :output, :url

    # Update the output filename unless we have a custom one passed
    def output=(output_file : String)
      @output = output_file unless @output != DEFAULT_FILE_NAME
    end

    def find_next(arg : Array(String), flag : String, default)
      search = arg.index flag
      if search
        return arg[search + 1]
      end

      return default
    end

    def initialize(arg : Array(String) = [] of String)
      @tmp = Dir.tempdir

      parser = OptionParser.new
      parser.banner = "Usage: muse-dl [--flags] URL"
      parser.on(long_flag = "--no-cleanup", description = "Don't cleanup temporary files") { @cleanup = false }
      parser.on(long_flag = "--tmp-dir PATH", description = "Temporary Directory to use") { |path| @tmp = path }
      parser.on(long_flag = "--output FILE", description = "Output Filename") { |file| @output = file }
      parser.on(long_flag = "--no-bookmarks", description = "Don't add bookmarks in the PDF") { @bookmarks = false }
      parser.on("-h", "--help", "Show this help") { puts parser }

      parser.unknown_args do |args|
        if args.size != 1
          puts parser
          exit 1
        end
        @url = args[0]
      end

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end

      parser.parse(arg)
    end
  end
end
