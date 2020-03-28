require "./infoparser.cr"
require "myhtml"

module Muse::Dl
  class Thing
    @info = Hash(String, String).new
    @title : String
    @author : String
    @date : String
    @publisher : String
    @summary : String
    @summary_html : String
    @cover_url : String
    @thumbnail_url : String
    @h : Myhtml::Parser

    getter :info, :title, :author, :date, :publisher, :summary, :summary_html, :cover_url, :thumbnail_url

    private getter :h

    def initialize(html : String)
      @h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      @title = InfoParser.title(h)
      @author = InfoParser.author(h)
      @date = InfoParser.date(h)
      @publisher = InfoParser.publisher(h)
      @summary = InfoParser.summary(h)
      @summary_html = InfoParser.summary_html(h)
      @cover_url = "TODO"
      @thumbnail_url = "TODO"
    end
  end
end
