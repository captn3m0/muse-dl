require "./thing.cr"
require "./fetch.cr"
require "./article.cr"

module Muse::Dl
  class Issue
    @id : String
    @title : String | Nil
    @articles : Array(Muse::Dl::Article)
    @url : String
    @info : Hash(String, String) | Nil
    @summary : String | Nil
    @publisher : String | Nil

    getter :id, :title, :articles, :url, :summary, :publisher, :info

    def initialize(id : String)
      @id = id
      @url = "https://muse.jhu.edu/issue/#{id}"
      @title = "NA"
      @articles = [] of Muse::Dl::Article
    end

    def parse
      html = Crest.get(url).to_s
      h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      @summary = InfoParser.summary(h)
      @publisher = InfoParser.journal_publisher(h)
    end
  end
end
