require "process"
require "file"
require "./fetch"
require "./errors/*"
require "dir"

module Muse::Dl
  class Pdftk
    PDFTK_BINARY_NAME = "pdftk"
    @binary = "/usr/sbin/pdftk"
    @tmp_file_path : String

    getter :binary

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
      Process.run(@binary, args)
    end

    def strip_first_page(input_file : String)
      output_pdf = File.tempfile("muse-dl-temp", ".pdf")
      execute [input_file, "cat", "2-end", "output", output_pdf.path]
      File.rename output_pdf.path, input_file
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
      execute [input_file, "update_info", bookmark_text_file.path, "output", output_pdf.path]

      # Cleanup
      bookmark_text_file.delete
      File.rename output_pdf.path, input_file
    end

    def add_metadata(input_file : File, output_file : String, book : Book)
      # First we have to dump the current metadata
      metadata_text_file = File.tempfile("muse-dl-metadata-tmp", ".txt")
      keywords = "Publisher:#{book.publisher}, Published:#{book.date}"

      # Known Info keys, if they are present
      ["ISBN", "Related ISBN", "DOI", "Language", "OCLC"].each do |label|
        if book.info.has_key? label
          keywords += ", #{label}:#{book.info[label]}"
        end
      end

      text = <<-EOT
      InfoBegin
      InfoKey: Creator
      InfoValue: Project MUSE (https://muse.jhu.edu/)
      InfoBegin
      InfoKey: Producer
      InfoValue: Muse-DL/#{Muse::Dl::VERSION}
      InfoBegin
      InfoKey: Title
      InfoValue: #{book.title}
      InfoBegin
      InfoKey: Keywords
      InfoValue: #{keywords}
      InfoBegin
      InfoKey: Author
      InfoValue: #{book.author}
      InfoBegin
      InfoKey: Subject
      InfoValue: #{book.summary.gsub(/\n\s+/, " ")}
      InfoBegin
      InfoKey: ModDate
      InfoValue:
      InfoBegin
      InfoKey: CreationDate
      InfoValue:
      EOT

      File.write(metadata_text_file.path, text)
      execute [input_file.path, "update_info_utf8", metadata_text_file.path, "output", output_file]
      metadata_text_file.delete
    end

    def stitch(chapter_ids : Array(String))
      output_file = File.tempfile("muse-dl-stitched-tmp", ".pdf")
      # Do some sanity checks on each Chapter PDF
      chapter_ids.each do |id|
        raise Muse::Dl::Errors::MissingChapter.new unless File.exists? Fetch.chapter_file_name(id, @tmp_file_path)
        raise Muse::Dl::Errors::CorruptFile.new unless File.size(Fetch.chapter_file_name(id, @tmp_file_path)) > 0
      end

      # Now let's stitch them together

      chapter_files = chapter_ids.map { |id| Fetch.chapter_file_name(id, @tmp_file_path) }
      args = chapter_files + ["cat", "output", output_file.path]
      execute args

      # TODO: Validate final file here

      return output_file
    end
  end
end
