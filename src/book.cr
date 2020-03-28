require "./thing.cr"

module Muse::Dl
  class Book < Muse::Dl::Thing
    @chapters : Array(Array(String))

    getter :chapters

    def initialize(html : String)
      super(html)
      @chapters = parts(@h)
    end

    def parts(myhtml : Myhtml::Parser)
      chapters = [] of Array(String)
      myhtml.css(".title a").each do |a|
        link = a.attribute_by("href").to_s
        matches = /\/chapter\/(\d+)/.match link
        if matches
          chapters.push [matches[1], a.inner_text]
        end
      end
      chapters
    end
  end
end
