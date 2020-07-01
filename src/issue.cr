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

    setter :journal_title

    def initialize(id : String, response : String | Nil = nil)
      @id = id
      @url = "https://muse.jhu.edu/issue/#{id}"
      @articles = [] of Muse::Dl::Article
      parse(response) if response
      @info = Hash(String, String).new
    end

    def open_access
      if @info.has_key? "Open Access"
        return @info["Open Access"] == "Yes"
      end
      false
    end

    def parse
      html = Crest.get(@url).to_s
      parse(html)
    end

    def parse(html : String)
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
        @date = /((January|February|March|April|May|June|July|August|September|October|November|December|Sring|Winter|Fall|Summer) (\d+))/.match(t).try &.[1]
        @date = /(\d{4})/.match(t).try &.[1] unless @date
      end
    end

    def parse_contents(myhtml : Myhtml::Parser)
      unless @journal_title
        journal_title_a = myhtml.css("#journal_banner_title a").first
        if journal_title_a
          @journal_title = journal_title_a.inner_text
        end
      end
      myhtml.css(".articles_list_text ol").each do |ol|
        link = ol.css("li.title a").first
        title = link.inner_text

        pages = ol.css("li.pg")
        if pages.size > 0
          p = pages.first.try &.inner_text
          matches = /(\d+)-(\d+)/.match p
          if matches
            start_page = matches[1].to_i
            end_page = matches[2].to_i
          end
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
