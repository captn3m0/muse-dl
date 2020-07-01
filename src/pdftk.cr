require "process"
require "file"
require "./fetch"
require "./errors/*"
require "dir"

module Muse::Dl
  class Pdftk
    PDFTK_BINARY_NAME = "pdftk"
    @binary : String | Nil
    @tmp_file_path : String

    def ready?
      @binary != nil
    end

    def initialize(tmp_file_path : String = Dir.tempdir)
      @tmp_file_path = tmp_file_path
      possible_binary = Process.find_executable(Pdftk::PDFTK_BINARY_NAME)
      if possible_binary
        @binary = possible_binary
      else
        puts "Could not find pdftk binary, exiting"
        Process.exit(1)
      end
    end

    def execute(args : Array(String))
      binary = @binary
      if binary
        status = Process.run(binary, args, output: STDOUT, error: STDERR)
        if !status.success?
          puts "pdftk command failed: #{binary} #{args.join(" ")}"
        end
        return status.success?
      end
    end

    def strip_first_page(input_file : String)
      output_pdf = File.tempfile("muse-dl-temp", ".pdf")
      is_success = execute [input_file, "cat", "2-end", "output", output_pdf.path]
      if is_success
        File.rename output_pdf.path, input_file
      else
        puts ("Error stripping first page of chapter. Maybe try using --dont-strip-first-page")
        exit 1
      end
    end

    def add_bookmark(input_file : String, title : String)
      output_pdf = File.tempfile("muse-dl-temp", ".pdf")
      bookmark_text_file = File.tempfile("muse-dl-chapter-tmp", ".txt")
      bookmark_text = <<-END
      BookmarkBegin
      BookmarkTitle: #{title}
      BookmarkLevel: 1
      BookmarkPageNumber: 1
      END
      File.write(bookmark_text_file.path, bookmark_text)
      is_success = execute [input_file, "update_info", bookmark_text_file.path, "output", output_pdf.path]

      # Cleanup
      bookmark_text_file.delete
      if is_success
        File.rename output_pdf.path, input_file
      else
        raise Muse::Dl::Errors::PDFOperationError.new("Error adding bookmark metadata to chapter.")
      end
    end

    def add_metadata(input_file : File, output_file : String, book : Book)
      # First we have to dump the current metadata
      keywords = "Publisher:#{book.publisher}, Published:#{book.date}"

      # Known Info keys, if they are present
      ["ISBN", "Related ISBN", "DOI", "Language", "OCLC"].each do |label|
        if book.info.has_key? label
          keywords += ", #{label}:#{book.info[label]}"
        end
      end

      metadata_text = gen_metadata(book.title, keywords, book.summary.gsub(/\n\s+/, " "), book.author)
      write_metadata(input_file, output_file, metadata_text)
    end

    def gen_metadata(title : String, keywords : String, subject : String, author : String | Nil = nil)
      metadata = <<-EOT
      InfoBegin
      InfoKey: Creator
      InfoValue:
      InfoBegin
      InfoKey: Producer
      InfoValue:
      InfoBegin
      InfoKey: Title
      InfoValue: #{title}
      InfoBegin
      InfoKey: Keywords
      InfoValue: #{keywords}
      InfoBegin
      InfoKey: Subject
      InfoValue: #{subject}
      InfoBegin
      InfoKey: ModDate
      InfoValue:
      InfoBegin
      InfoKey: CreationDate
      InfoValue:

      EOT

      unless author.nil?
        metadata += <<-EOT
        InfoBegin
        InfoKey: Author
        InfoValue: #{author}
        EOT
      end

      return metadata
    end

    def write_metadata(input_file : File, output_file : String, text)
      metadata_text_file = File.tempfile("muse-dl-metadata-tmp", ".txt")
      File.write(metadata_text_file.path, text)

      is_success = execute [input_file.path, "update_info_utf8", metadata_text_file.path, "output", output_file]
      if !is_success
        raise Muse::Dl::Errors::PDFOperationError.new("Error adding metadata to book.")
      end
      metadata_text_file.delete
    end

    def add_metadata(input_file : File, output_file : String, issue : Issue)
      # First we have to dump the current metadata
      metadata_text_file = File.tempfile("muse-dl-metadata-tmp", ".txt")
      keywords = "Journal:#{issue.journal_title}, Published:#{issue.date},Volume:#{issue.volume},Number:#{issue.number}"
      ["ISSN", "Print ISSN", "DOI", "Language", "Open Access"].each do |label|
        if issue.info.has_key? label
          keywords += ", #{label}:#{issue.info[label]}"
        end
      end

      # TODO: Move this to Issue class

      s = issue.summary
      unless s.nil?
        summary = s.gsub(/\n\s+/, " ")
      else
        summary = "NA"
      end

      t = issue.title

      unless t.nil?
        title = t
      else
        title = "NA"
      end
      # TODO: Add support for all authors in the PDF
      metadata = gen_metadata(title, keywords, summary)
      write_metadata(input_file, output_file, metadata)
    end

    def stitch(chapter_ids : Array(String))
      output_file = File.tempfile("muse-dl-stitched-tmp", ".pdf")
      # Do some sanity checks on each Chapter PDF
      chapter_ids.each do |id|
        raise Muse::Dl::Errors::MissingFile.new unless File.exists? Fetch.chapter_file_name(id, @tmp_file_path)
        raise Muse::Dl::Errors::CorruptFile.new unless File.size(Fetch.chapter_file_name(id, @tmp_file_path)) > 0
      end

      # Now let's stitch them together

      chapter_files = chapter_ids.map { |id| Fetch.chapter_file_name(id, @tmp_file_path) }
      args = chapter_files + ["cat", "output", output_file.path]
      is_success = execute args

      # TODO: Validate final file here
      if !is_success
        raise Muse::Dl::Errors::PDFOperationError.new("Error stitching chapters together.")
      end

      return output_file
    end

    # TODO: Merge with stitch
    def stitch_articles(article_ids : Array(String))
      output_file = File.tempfile("muse-dl-stitched-tmp", ".pdf")
      # Do some sanity checks on each Chapter PDF
      article_ids.each do |id|
        raise Muse::Dl::Errors::MissingFile.new unless File.exists? Fetch.article_file_name(id, @tmp_file_path)
        raise Muse::Dl::Errors::CorruptFile.new unless File.size(Fetch.article_file_name(id, @tmp_file_path)) > 0
      end

      # Now let's stitch them together
      article_files = article_ids.map { |id| Fetch.article_file_name(id, @tmp_file_path) }
      args = article_files + ["cat", "output", output_file.path]
      is_success = execute args

      # TODO: Validate final file here
      if !is_success
        puts args
        raise Muse::Dl::Errors::PDFOperationError.new("Error stitching articles together.")
      end

      return output_file
    end
  end
end
