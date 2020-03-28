require "./infoparser.cr"

module Muse::Dl
  class Journal
    @info = Hash(String, String).new
    getter :info

    def initialize(html : String)
      @info = InfoParser.parse(html)
    end
  end
end
