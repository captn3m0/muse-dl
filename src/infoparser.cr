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

    def self.title(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .title").map(&.inner_text).to_a[0].strip
    end

    def self.author(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .author").map(&.inner_text).to_a[0].strip.gsub("<BR>", ", ").gsub("\n", " ")
    end

    def self.date(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .date").map(&.inner_text).to_a[0].strip
    end

    def self.publisher(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .pub a").map(&.inner_text).to_a[0].strip
    end

    def self.summary(myhtml : Myhtml::Parser)
      begin
        return myhtml.css("#book_about_info .card_summary").map(&.inner_text).to_a[0].strip
      rescue e : Exception
        STDERR.puts "Could not fetch summary"
        return "NA"
      end
    end

    def self.summary_html(myhtml : Myhtml::Parser)
      return "TODO"
      myhtml.css("#book_about_info .card_summary").map(&.tag_text).to_a[0].strip
    end
  end
end
