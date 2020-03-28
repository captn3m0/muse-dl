require "myhtml"

module Muse::Dl
  class InfoParser
    def self.parse(html : String)
      info = Hash(String, String).new
      myhtml = Myhtml::Parser.new(html)
      myhtml.css(".details_row").each do |row|
        label = row.css(".cell").map(&.inner_text).to_a[0].strip
        value = row.css(".cell").map(&.inner_text).to_a[1].strip
        case label
        when "MARC Record"
        else
          info[label] = value
        end
      end
      return info
    end
  end
end
