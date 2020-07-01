require "./infoparser.cr"
require "./issue.cr"

module Muse::Dl
  class Journal
    getter :info, :summary, :publisher, :issues, :title
    @info = Hash(String, String).new
    @summary : String
    @publisher : String
    @issues = [] of Muse::Dl::Issue
    @title : String

    private getter :h

    def initialize(html)
      @h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      @summary = InfoParser.summary(h)
      @publisher = InfoParser.journal_publisher(h)
      @title = InfoParser.journal_title(h)
      parse_volumes(h)
    end

    def open_access
      if @info.has_key? "Open Access"
        return @info["Open Access"] == "Yes"
      end
      false
    end

    def parse_volumes(myhtml : Myhtml::Parser)
      myhtml.css("#available_issues_list_text a").each do |a|
        link = a.attribute_by("href").to_s

        matches = /\/issue\/(\d+)/.match link
        if matches
          issue = Muse::Dl::Issue.new matches[1]
          issue.journal_title = @title
          @issues.push issue
        end
      end
    end
  end
end
