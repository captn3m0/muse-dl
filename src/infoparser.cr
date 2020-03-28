require "myhtml"

module Muse::Dl
  class InfoParser
    def self.infobox(myhtml : Myhtml::Parser)
      info = Hash(String, String).new
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

    def self.title
    end
  end
end
