require "./errors/missing_link.cr"

module Muse::Dl
  class Parser
    @bookmarks : Bool
    @tmp : String
    @cleanup : Bool
    @output : String
    @url = "INVALID_URL"

    getter :bookmarks, :tmp, :cleanup, :output, :url

    def find_next(arg : Array(String), flag : String, default)
      search = arg.index flag
      if search
        return arg[search + 1]
      end

      return default
    end

    def initialize(arg : Array(String) = [] of String)
      @bookmarks = !arg.index "--no-bookmarks"
      @cleanup = !arg.index "--no-cleanup"
      @tmp = find_next(arg, "--tmp-dir", "/tmp")
      @output = find_next(arg, "--output", "tempfilename.pdf")
      begin
        @url = arg[-1]
      rescue e : Exception
        @url = ""
        raise Errors::MissingLink.new
      end
    end
  end
end
