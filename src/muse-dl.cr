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
          Fetch.save_chapter(parser.tmp, chapter[0], chapter[1], parser.bookmarks)
        end
        chapter_ids = thing.chapters.map { |c| c[0] }
        pdf_builder = Pdftk.new(parser.tmp)
        temp_stitched_file = pdf_builder.stitch chapter_ids
        pdf_builder.add_metadata(temp_stitched_file, parser.output, thing)
        temp_stitched_file.delete
        puts "Saved final output to #{parser.output}"
      end
    end
  end
end

Muse::Dl::Main.run(ARGV)
