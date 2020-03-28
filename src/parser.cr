module Muse::Dl
  class Parser
    @bookmarks : Bool
    @tmp : String
    @cleanup : Bool
    @output : String

    getter :bookmarks, :tmp, :cleanup, :output

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
    end
  end
end
