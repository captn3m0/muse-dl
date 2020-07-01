require "./infoparser.cr"
require "myhtml"

module Muse::Dl
  class Thing
    @info = Hash(String, String).new
    @title : String
    @author : String
    @date : String | Nil
    @publisher : String
    @summary : String
    @summary_html : String
    @cover_url : String
    @thumbnail_url : String
    @h : Myhtml::Parser
    @formats : Set(Symbol)

    getter :info, :title, :author, :date, :publisher, :summary, :summary_html, :cover_url, :thumbnail_url, :formats

    private getter :h

    def open_access
      if @info.has_key? "Open Access"
        return @info["Open Access"] == "Yes"
      end
      false
    end

    def initialize(html : String)
      @h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      id : String | Nil = InfoParser.id(h)
      @title = InfoParser.title(h)
      @author = InfoParser.author(h)
      @date = InfoParser.date(h)
      @publisher = InfoParser.publisher(h)
      @summary = InfoParser.summary(h)
      @summary_html = InfoParser.summary_html(h)
      @formats = InfoParser.formats(h)
      # TODO: Make this work for journals as well
      @cover_url = "https://muse.jhu.edu/book/#{id}/image/front_cover.jpg"
      @thumbnail_url = "https://muse.jhu.edu/book/#{id}/image/front_cover.jpg?format=180"
    end
  end
end
