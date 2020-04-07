require "myhtml"

# https://github.com/kostya/myhtml/issues/19
struct Myhtml::Node
  def inner_html
    String.build { |buf| children.each &.to_html(buf) }
  end
end

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

    def self.id(myhtml : Myhtml::Parser)
      searchid = myhtml.css("#search_within_book_id").first
      if searchid
        searchid.attribute_by("value")
      end
    end

    def self.title(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .title").map(&.inner_text).to_a[0].strip
    end

    def self.issue_title(myhtml : Myhtml::Parser)
      myhtml.css(".card_text .title").map(&.inner_text).to_a[0].strip
    end

    def self.author(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .author").map(&.inner_text).to_a[0].strip.gsub("<BR>", ", ").gsub("\n", " ")
    end

    def self.date(myhtml : Myhtml::Parser)
      begin
        myhtml.css("#book_about_info .date").map(&.inner_text).to_a[0].strip
      rescue e : Exception
        nil
      end
    end

    def self.publisher(myhtml : Myhtml::Parser)
      myhtml.css("#book_about_info .pub a").map(&.inner_text).to_a[0].strip
    end

    def self.journal_publisher(myhtml : Myhtml::Parser)
      myhtml.css(".card_publisher a").map(&.inner_text).to_a[0].strip
    end

    def self.summary(myhtml : Myhtml::Parser)
      begin
        return myhtml.css(".card_summary").map(&.inner_text).to_a[0].strip
      rescue e : Exception
        STDERR.puts "Could not fetch summary"
        return "NA"
      end
    end

    def self.summary_html(myhtml : Myhtml::Parser)
      summary_div = myhtml.css("#book_about_info .card_summary")
      begin
        summary_div.first.inner_html
      rescue e : Exception
        "NA"
      end
    end

    def self.formats(myhtml : Myhtml::Parser)
      formats = Set(Symbol).new
      myhtml.css("img.icon").each do |icon|
        url = icon.attribute_by("src")
        if url
          formats.add :html if /html/i.match url
          formats.add :pdf if /pdf/i.match url
        end
      end
      formats
    end
  end
end
