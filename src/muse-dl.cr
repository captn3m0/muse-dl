require "./parser.cr"
require "./pdftk.cr"
require "./fetch.cr"
require "./book.cr"
require "./journal.cr"
require "./util.cr"

module Muse::Dl
  VERSION = "0.1.0"

  class Main
    def self.run(args : Array(String))
      parser = Parser.new(args)
      thing = Fetch.get_info(parser.url)

      if thing.is_a? Muse::Dl::Book
        # Will have no effect if parser has a custom title
        parser.output = Util.slug_filename "#{thing.title}.pdf"

        # Save each chapter
        thing.chapters.each do |chapter|
          Fetch.save_chapter(parser.tmp, chapter[0], chapter[1], parser.bookmarks)
        end
        chapter_ids = thing.chapters.map { |c| c[0] }

        # Stitch the PDFs together
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
