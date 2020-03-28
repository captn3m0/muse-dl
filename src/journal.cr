require "./infoparser.cr"
require "myhtml"

module Muse::Dl
  class Journal
    @info = Hash(String, String).new
    getter :info

    def initialize(html : String)
      @info = InfoParser.infobox(Myhtml::Parser.new html)
    end
  end
end
