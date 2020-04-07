require "./infoparser.cr"
require "./issue.cr"

module Muse::Dl
  class Journal
    getter :info, :summary, :publisher, :issues
    @info = Hash(String, String).new
    @summary : String
    @publisher : String
    @issues = [] of Muse::Dl::Issue

    private getter :h

    def initialize(html)
      @h = Myhtml::Parser.new html
      @info = InfoParser.infobox(h)
      @summary = InfoParser.summary(h)
      @publisher = InfoParser.journal_publisher(h)
      parse_volumes(h)
    end

    def parse_volumes(myhtml : Myhtml::Parser)
      myhtml.css("#available_issues_list_text a").each do |a|
        link = a.attribute_by("href").to_s

        matches = /\/issue\/(\d+)/.match link
        if matches
          @issues.push Muse::Dl::Issue.new matches[1]
        end
      end
    end
  end
end
