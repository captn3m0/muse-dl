require "crest"
require "./errors/*"
require "myhtml"

module Muse::Dl
  class Fetch
    USER_AGENT            = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    DOWNLOAD_TIMEOUT_SECS = 60

    HEADERS = {
      "User-Agent"      => USER_AGENT,
      "Accept"          => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Accept-Language" => "en-US,en;q=0.5",
      "Connection"      => "keep-alive",
    }

    def self.article_file_name(id : String, tmp_path : String)
      "#{tmp_path}/article-#{id}.pdf"
    end

    def self.chapter_file_name(id : String, tmp_path : String)
      "#{tmp_path}/chapter-#{id}.pdf"
    end

    def self.cleanup(tmp_path : String, id : String)
      fns = chapter_file_name(id, tmp_path)
      File.delete(fns) if File.exists?(fns)
    end

    def self.cleanup_articles(tmp_path : String, id : String)
      fns = article_file_name(id, tmp_path)
      File.delete(fns) if File.exists?(fns)
    end

    def self.save_url(url : String, referer : String, file_name : String, tmp_path : String, cookie : String | Nil = nil, bookmark_title : String | Nil = nil, strip_first_page = true)
      tmp_pdf_file = "#{file_name}.tmp"
      if File.exists? file_name
        puts "#{file_name} already downloaded"
        return
      end

      uri = URI.parse(url)
      http_client = HTTP::Client.new(uri)
      # Raise a IO::TimeoutError after 60 seconds.
      http_client.read_timeout = DOWNLOAD_TIMEOUT_SECS

      headers = HEADERS.merge({
        "Referer" => referer,
      })

      if cookie
        headers["Cookie"] = cookie
      end

      request = Crest::Request.new(:get, url, headers: headers, max_redirects: 0, handle_errors: false)

      begin
        response = request.execute
      rescue ex : IO::TimeoutError
        raise Muse::Dl::Errors::DownloadError.new("Error downloading #{url}. Download took longer than #{DOWNLOAD_TIMEOUT_SECS} seconds.")
      end

      # TODO: Add validation for the downloaded file (should be PDF)
      if !response.success?
        raise Muse::Dl::Errors::DownloadError.new("Error downloading chapter. HTTP response code: #{response.status}")
      end

      content_type = response.headers["Content-Type"]
      if content_type.is_a? String
        if /html/.match content_type
          response.body.each_line do |line|
            # https://muse.jhu.edu/chapter/2383438/pdf
            # https://muse.jhu.edu/book/67393
            # Errors are Unable to determine page runs / Unable to construct chapter PDF
            if /Unable to/.match line
              raise Muse::Dl::Errors::MuseCorruptPDF.new("Error: MUSE is unable to generate PDF for #{url}")
            end
            if /Your IP has requested/.match line
              raise Muse::Dl::Errors::DownloadError.new("Error: MUSE Rate-limit reached")
            end
          end
        end
      end

      File.open(tmp_pdf_file, "w") do |file|
        file << response.body
        if file.size == 0
          raise Muse::Dl::Errors::DownloadError.new("Error: downloaded chapter file size is zero. Response Content-Length header was #{headers["Content-Length"]}")
        end
      end

      pdftk = Muse::Dl::Pdftk.new tmp_path

      pdftk.strip_first_page tmp_pdf_file if strip_first_page

      if bookmark_title
        # Run pdftk and add the bookmark to the file
        pdftk.add_bookmark tmp_pdf_file, bookmark_title
      end

      # Now we can move the file to the proper PDF filename
      File.rename tmp_pdf_file, file_name
    end

    def self.save_chapter(tmp_path : String, chapter_id : String, chapter_title : String, cookie : String | Nil = nil, add_bookmark = true, strip_first_page = true)
      final_pdf_file = chapter_file_name chapter_id, tmp_path

      if File.exists? final_pdf_file
        puts "#{chapter_id} already downloaded"
        return
      end

      # TODO: Remove this hardcoding, and make this more generic by generating it within the Book class
      url = "https://muse.jhu.edu/chapter/#{chapter_id}/pdf"
      referer = "https://muse.jhu.edu/verify?url=%2Fchapter%2F#{chapter_id}%2Fpdf"

      save_url(url, referer, final_pdf_file, tmp_path, cookie, chapter_title, strip_first_page)

      puts "Downloaded #{chapter_id}"
    end

    def self.save_article(tmp_path : String, article_id : String, cookie : String | Nil = nil, article_title = nil, strip_first_page = true)
      file_name = article_file_name article_id, tmp_path
      url = "https://muse.jhu.edu/article/#{article_id}/pdf"
      referer = "https://muse.jhu.edu/article/#{article_id}"
      save_url(url, referer, file_name, tmp_path, cookie, article_title, strip_first_page)
    end

    def self.get_info(url : String)
      match = /https:\/\/muse.jhu.edu\/(book|journal|issue|article)\/(\d+)/.match url
      if match
        begin
          response = Crest.get(url).to_s
          case match[1]
          when "book"
            return Muse::Dl::Book.new response
          when "journal"
            return Muse::Dl::Journal.new response
          when "issue"
            return Muse::Dl::Issue.new match[2], response
          when "article"
            return Muse::Dl::Article.new match[2]
          end
        rescue ex : Crest::NotFound
          raise Muse::Dl::Errors::InvalidLink.new("Error - could not download url: #{url}")
        end
      else
        raise Muse::Dl::Errors::InvalidLink.new("Error - url does not match expected pattern: #{url}")
      end
    end
  end
end
