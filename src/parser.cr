require "option_parser"
require "dir"

module Muse::Dl
  class Parser
    @bookmarks = true
    @tmp : String
    @cleanup = true
    @output = DEFAULT_FILE_NAME
    @url : String | Nil
    @input_pdf : String | Nil
    @clobber = false
    @input_list : String | Nil

    DEFAULT_FILE_NAME = "tempfilename.pdf"

    getter :bookmarks, :tmp, :cleanup, :output, :url, :input_pdf, :clobber, :input_list
    setter :url

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
      @input_pdf = nil

      parser = OptionParser.new
      parser.banner = <<-EOT
      Usage: muse-dl [--flags] [URL|INPUT_FILE]

      URL: A link to a book on the Project MUSE website, eg https://muse.jhu.edu/book/875
      INPUT_FILE: Path to a file containing a list of links

      EOT
      parser.on(long_flag = "--no-cleanup", description = "Don't cleanup temporary files") { @cleanup = false }
      parser.on(long_flag = "--tmp-dir PATH", description = "Temporary Directory to use") { |path| @tmp = path }
      parser.on(long_flag = "--output FILE", description = "Output Filename") { |file| @output = file }
      parser.on(long_flag = "--no-bookmarks", description = "Don't add bookmarks in the PDF") { @bookmarks = false }
      parser.on(long_flag = "--input-pdf INPUT", description = "Input Stitched PDF. Will not download anything") { |input| @input_pdf = input }
      parser.on(long_flag = "--clobber", description = "Overwrite the output file, if it already exists. Not compatible with input-pdf") { @clobber = true }
      parser.on("-h", "--help", "Show this help") { puts parser }

      parser.unknown_args do |args|
        if args.size != 1
          puts parser
          exit 1
        end
        if File.exists? args[0]
          @input_list = args[0]
          @input_pdf = nil
        else
          @url = args[0]
        end
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
