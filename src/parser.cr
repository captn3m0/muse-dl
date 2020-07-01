require "option_parser"
require "dir"

module Muse::Dl
  class Parser
    @bookmarks = true
    @tmp : String
    @cleanup = true
    # Whether to strip the first page
    @strip_first = true
    @output = DEFAULT_FILE_NAME
    @url : String | Nil
    @clobber = false
    @input_list : String | Nil
    @cookie : String | Nil
    @h : Bool | Nil
    @skip_oa = false

    DEFAULT_FILE_NAME = "tempfilename.pdf"

    getter :bookmarks, :tmp, :cleanup, :output, :url, :clobber, :input_list, :cookie, :strip_first, :skip_oa
    setter :url

    # Update the output filename unless we have a custom one passed
    def output=(output_file : String)
      @output = output_file unless @output != DEFAULT_FILE_NAME
    end

    def force_set_output(output_file : String)
      @output = output_file
    end

    def reset_output_file
      @output = DEFAULT_FILE_NAME
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
      parser.banner = <<-EOT
      Usage: muse-dl [--flags] [URL|INPUT_FILE]

      URL: A link to a book on the Project MUSE website, eg https://muse.jhu.edu/book/875
      INPUT_FILE: Path to a file containing a list of links

      EOT

      parser.on(long_flag = "--no-cleanup", description = "Don't cleanup temporary files") { @cleanup = false }
      parser.on(long_flag = "--tmp-dir PATH", description = "Temporary Directory to use") { |path| @tmp = path }
      parser.on(long_flag = "--output FILE", description = "Output Filename") { |file| @output = file }
      parser.on(long_flag = "--no-bookmarks", description = "Don't add bookmarks in the PDF") { @bookmarks = false }
      parser.on(long_flag = "--clobber", description = "Overwrite the output file, if it already exists.") { @clobber = true }
      parser.on(long_flag = "--dont-strip-first-page", description = "Disables first page from being stripped. Use carefully") { @strip_first = false }
      parser.on(long_flag = "--cookie COOKIE", description = "Cookie-header") { |cookie| @cookie = cookie }
      parser.on(long_flag = "--skip-open-access", description = "Don't download open access content") { @skip_oa = true }
      parser.on("-h", "--help", "Show this help") { @h = true; puts parser }

      parser.unknown_args do |args|
        if args.size != 1
          # Prevent showing helptext twice
          puts parser unless @h
          exit 1
        end
        if File.exists? args[0]
          @input_list = args[0]
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
