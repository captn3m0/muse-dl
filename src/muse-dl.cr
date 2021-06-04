require "./parser.cr"
require "./pdftk.cr"
require "./fetch.cr"
require "./book.cr"
require "./journal.cr"
require "./util.cr"
require "file_utils"

module Muse::Dl
  VERSION = "1.3.1"

  class Main
    def self.dl(parser : Parser)
      url = parser.url
      puts "Downloading #{url}"
      thing = Fetch.get_info(url) if url
      return unless thing

      if (thing.open_access) && (parser.skip_oa)
        STDERR.puts "Skipping #{url}, available under Open Access"
        return
      end

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

        # Save each chapter
        thing.chapters.each do |chapter|
          begin
            Fetch.save_chapter(parser.tmp, chapter[0], chapter[1], parser.cookie, parser.bookmarks, parser.strip_first)
          rescue e : Muse::Dl::Errors::MuseCorruptPDF
            STDERR.puts "Got a 'Unable to construct chapter PDF' error from MUSE, skipping: #{url}"
            return
          end
        end
        chapter_ids = thing.chapters.map { |c| c[0] }

        # Stitch the PDFs together
        temp_stitched_file = pdf_builder.stitch chapter_ids
        pdf_builder.add_metadata(temp_stitched_file, parser.output, thing)

        temp_stitched_file.delete if temp_stitched_file
        puts "--dont-strip-first-page was on. Please validate PDF file for any errors." unless parser.strip_first
        puts "DL: #{url}. Saved final output to #{parser.output}"

        # Cleanup the chapter files
        if parser.cleanup
          thing.chapters.each do |c|
            Fetch.cleanup(parser.tmp, c[0])
          end
        end
      elsif thing.is_a? Muse::Dl::Article
        # No bookmarks are needed since this is just a single article PDF
        begin
          Fetch.save_article(parser.tmp, thing.id, parser.cookie, nil, parser.strip_first)
        rescue e : Muse::Dl::Errors::MuseCorruptPDF
          STDERR.puts "Got a 'Unable to construct chapter PDF' error from MUSE, skipping: #{url}"
          return
        end

        # TODO: Move this code elsewhere
        source = Fetch.article_file_name(thing.id, parser.tmp)
        destination = "article-#{thing.id}.pdf"
        # Needed because of https://github.com/crystal-lang/crystal/issues/7777
        FileUtils.cp source, destination
        FileUtils.rm source if parser.cleanup
      elsif thing.is_a? Muse::Dl::Issue
        # Will have no effect if parser has a custom title
        parser.force_set_output Util.slug_filename "#{thing.journal_title} - #{thing.title}.pdf"

        # If file exists and we can't clobber
        if File.exists?(parser.output) && parser.clobber == false
          STDERR.puts "Skipping #{url}, File already exists: #{parser.output}"
          return
        end
        temp_stitched_file = nil
        pdf_builder = Pdftk.new(parser.tmp)

        thing.articles.each do |article|
          begin
            Fetch.save_article(parser.tmp, article.id, parser.cookie, article.title, parser.strip_first)
          rescue e : Muse::Dl::Errors::MuseCorruptPDF
            STDERR.puts "Got a 'Unable to construct chapter PDF' error from MUSE, skipping: #{url}"
            return
          end
        end
        article_ids = thing.articles.map { |a| a.id }

        # Stitch the PDFs together
        temp_stitched_file = pdf_builder.stitch_articles article_ids
        pdf_builder.add_metadata(temp_stitched_file, parser.output, thing)

        # temp_stitched_file.delete if temp_stitched_file
        puts "--dont-strip-first-page was on. Please validate PDF file for any errors." unless parser.strip_first
        puts "DL: #{url}. Saved final output to #{parser.output}"

        # Cleanup the issue files
        if parser.cleanup
          thing.articles.each do |a|
            Fetch.cleanup_articles(parser.tmp, a.id)
          end
        end
      elsif thing.is_a? Muse::Dl::Journal
        thing.issues.each do |issue|
          begin
            # Update the issue
            issue.parse
            parser.url = issue.url
            Main.dl parser
          rescue e
            puts e.message
            puts "Faced an exception with previous issue, continuing"
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
          rescue ex
            puts ex.message
            puts ex.backtrace.join("\n    ")
            puts "Error. Skipping book: #{url}. Waiting for #{delay_secs} seconds before continuing."
            sleep(delay_secs)
            if delay_secs < 256
              delay_secs *= 2
            end
          end
        end
      elsif parser.url
        Main.dl parser
      end
    end
  end
end

Muse::Dl::Main.run(ARGV)
