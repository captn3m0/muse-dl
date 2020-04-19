require "./parser.cr"
require "./pdftk.cr"
require "./fetch.cr"
require "./book.cr"
require "./journal.cr"
require "./util.cr"

module Muse::Dl
  VERSION = "1.1.2"

  class Main
    def self.dl(parser : Parser)
      url = parser.url
      thing = Fetch.get_info(url) if url
      return unless thing

      if thing.is_a? Muse::Dl::Book
        unless thing.formats.includes? :pdf
          STDERR.puts "Book not available in PDF format, skipping: #{url}"
          return
        end
        # Will have no effect if parser has a custom title
        parser.output = Util.slug_filename "#{thing.title}.pdf"

        # If file exists and we can't clobber
        if File.exists?(parser.output) && parser.clobber == false
          STDERR.puts "Skipping #{url}, File already exists: #{parser.output}"
          return
        end
        temp_stitched_file = nil
        pdf_builder = Pdftk.new(parser.tmp)

        unless parser.input_pdf
          # Save each chapter
          thing.chapters.each do |chapter|
            begin
              Fetch.save_chapter(parser.tmp, chapter[0], chapter[1], parser.cookie, parser.bookmarks)
            rescue e : Muse::Dl::Errors::MuseCorruptPDF
              STDERR.puts "Got a 'Unable to construct chapter PDF' error from MUSE, skipping: #{url}"
              return
            end
          end
          chapter_ids = thing.chapters.map { |c| c[0] }

          # Stitch the PDFs together
          temp_stitched_file = pdf_builder.stitch chapter_ids
          pdf_builder.add_metadata(temp_stitched_file, parser.output, thing)
        else
          x = parser.input_pdf
          pdf_builder.add_metadata(File.open(x), parser.output, thing) if x
        end

        temp_stitched_file.delete if temp_stitched_file
        puts "DL: #{url}. Saved final output to #{parser.output}"

        # Cleanup the chapter files
        if parser.cleanup
          thing.chapters.each do |c|
            Fetch.cleanup(parser.tmp, c[0])
          end
        end
      end
    end

    def self.run(args : Array(String))
      parser = Parser.new(args)

      delay_secs = 1
      input_list = parser.input_list
      if input_list
        File.each_line input_list do |url|
          begin
            # TODO: Change this to nil
            parser.reset_output_file
            parser.url = url.strip
            # Ask the download process to not quit the process, and return instead
            Main.dl parser
            if delay_secs >= 2
              delay_secs /= 2
            end
          rescue ex : Muse::Dl::Errors::DownloadError
            puts ex.backtrace.join("\n    ")
            puts "Download error. Skipping book: #{url}. Waiting for #{delay_secs} seconds before continuing."
            # Sleep to prevent hammering the server.
            sleep(delay_secs)
            delay_secs *= 2
          rescue ex
            puts ex.backtrace.join("\n    ")
            pp ex
            puts "Non-download error. Skipping book: #{url}."
            sleep(1)
          end
        end
      elsif parser.url
        Main.dl parser
      end
    end
  end
end

Muse::Dl::Main.run(ARGV)
