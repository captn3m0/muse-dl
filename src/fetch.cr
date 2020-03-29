require "crest"
require "./errors/*"

module Muse::Dl
  class Fetch
    USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"

    HEADERS = {
      "User-Agent"      => USER_AGENT,
      "Accept"          => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Accept-Language" => "en-US,en;q=0.5",
      "Connection"      => "keep-alive",
    }

    def self.chapter_file_name(id : String, tmp_path : String)
      "#{tmp_path}/chapter-#{id}.pdf"
    end

    def self.save_chapter(tmp_path : String, chapter_id : String, chapter_title : String, cookie : String | Nil = nil, add_bookmark = true)
      final_pdf_file = chapter_file_name chapter_id, tmp_path
      tmp_pdf_file = "#{final_pdf_file}.tmp"

      if File.exists? final_pdf_file
        puts "#{chapter_id} already downloaded"
        return
      end

      url = "https://muse.jhu.edu/chapter/#{chapter_id}"
      headers = HEADERS.merge({
        "Referer" => "https://muse.jhu.edu/verify?url=%2Fchapter%2F#{chapter_id}%2Fpdf",
      })

      if cookie
        headers["Cookie"] = cookie
      end

      # TODO: Add validation for the downloaded file (should be PDF)
      Crest.get(url, max_redirects: 0, handle_errors: false, headers: headers) do |response|
        File.open(tmp_pdf_file, "w") do |file|
          IO.copy(response.body_io, file)
        end
      end

      pdftk = Muse::Dl::Pdftk.new tmp_path

      pdftk.strip_first_page tmp_pdf_file

      if add_bookmark
        # Run pdftk and add the bookmark to the file
        pdftk.add_bookmark tmp_pdf_file, chapter_title
      end

      # Now we can move the file to the proper PDF filename
      File.rename tmp_pdf_file, final_pdf_file
      puts "Downloaded #{chapter_id}"
    end

    def self.get_info(url : String) : Muse::Dl::Thing | Nil
      match = /https:\/\/muse.jhu.edu\/(book|journal)\/(\d+)/.match url
      if match
        begin
          response = Crest.get(url).to_s
          case match[1]
          when "book"
            return Muse::Dl::Book.new response
          when "journal"
            return Muse::Dl::Journal.new response
          end
        rescue ex : Crest::NotFound
          raise Muse::Dl::Errors::InvalidLink.new
        end
      else
        raise Muse::Dl::Errors::InvalidLink.new
      end
    end
  end
end
