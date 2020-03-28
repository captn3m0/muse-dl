require "./parser.cr"
require "./pdftk.cr"
require "./fetch.cr"
require "./book.cr"
require "./journal.cr"

# TODO: Write documentation for `Muse::Dl`
module Muse::Dl
  VERSION = "0.1.0"

  # TODO: Put your code here
  class Main
    def self.run(args : Array(String))
      parser = Parser.new(args)
      thing = Fetch.get_info(parser.url)

      if thing.is_a? Muse::Dl::Book
        thing.chapters.each do |chapter|
          Fetch.save_chapter(parser.tmp, chapter[0])
        end
      end
    end
  end
end

Muse::Dl::Main.run(ARGV)
