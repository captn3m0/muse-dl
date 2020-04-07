require "./infoparser.cr"
require "myhtml"

module Muse::Dl
  class Journal
    getter :info, :summary, :publisher
    @info = Hash(String, String).new
    @summary : String
    @publisher : String

    private getter :h

    def initialize(html)
      @h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      @summary = InfoParser.summary(h)
      @publisher = InfoParser.journal_publisher(h)
    end
  end
end
