"./thing.cr"
require "./fetch.cr"
require "./article.cr"

module Muse::Dl
  class Issue
    getter id : String,
      title : String | Nil,
      articles : Array(Muse::Dl::Article),
      url : String,
      summary : String | Nil,
      publisher : String | Nil,
      info : Hash(String, String),
      volume : String | Nil,
      number : String | Nil,
      date : String | Nil,
      journal_title : String | Nil

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
      parse_contents(h)
    end

    def parse_title
      t = @title
      unless t.nil?
        @volume = /Volume (\d+)/.match(t).try &.[1]
        @number = /Number (\d+)/.match(t).try &.[1]
        @number = /Issue (\d+)/.match(t).try &.[1] unless @number
        @date = /((January|February|March|April|May|June|July|August|September|October|November|December) (\d+))/.match(t).try &.[1]
        @date = /(\d{4})/.match(t).try &.[1] unless @date
      end
    end

    def parse_contents(myhtml : Myhtml::Parser)
      journal_title_a = myhtml.css("#journal_banner_title a").first
      if journal_title_a
        @journal_title = journal_title_a.inner_text
      end
      myhtml.css(".articles_list_text ol").each do |ol|
        link = ol.css("li.title a").first
        title = link.inner_text

        pages = ol.css("li.pg").first.try &.inner_text
        matches = /(\d+)-(\d+)/.match pages
        if matches
          start_page = matches[1].to_i
          end_page = matches[2].to_i
        end

        ol.css("a").each do |l|
          url = l.attribute_by("href").to_s
          matches = /\/article\/(\d+)\/pdf/.match url
          if matches
            a = Muse::Dl::Article.new matches[1]
            a.title = title
            a.start_page = start_page if start_page
            a.end_page = end_page if end_page
            @articles.push a
          end
        end
      end
    end
  end
end
