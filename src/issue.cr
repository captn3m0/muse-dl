require "./thing.cr"
require "./fetch.cr"
require "./article.cr"

module Muse::Dl
  class Issue
    @id : String
    @title : String | Nil
    @articles : Array(Muse::Dl::Article)
    @url : String
    @info : Hash(String, String)
    @summary : String | Nil
    @publisher : String | Nil
    @volume : String | Nil
    @number : String | Nil
    @date : String | Nil

    getter :id, :title, :articles, :url, :summary, :publisher, :info, :volume, :number, :date

    def initialize(id : String)
      @id = id
      @url = "https://muse.jhu.edu/issue/#{id}"
      @info = Hash(String, String).new
      @articles = [] of Muse::Dl::Article
    end

    def parse
      html = Crest.get(url).to_s
      h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      @title = InfoParser.issue_title(h)
      @summary = InfoParser.summary(h)
      @publisher = InfoParser.journal_publisher(h)
      parse_title
    end

    def parse_title
      t = @title
      unless t.nil?
        @volume = /Volume (\d+)/.match(t).try &.[1]
        @number = /Number (\d+)/.match(t).try &.[1]
        @date = /((January|February|March|April|May|June|July|August|September|October|November|December) (\d+))/.match(t).try &.[1]
      end
    end
  end
end
