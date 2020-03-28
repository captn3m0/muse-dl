require "crest"
require "./errors/*"

module Muse::Dl
  class Fetch
    USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    # TODO: Add support for cookies?
    # "Cookie"                    => "session=124.123.104.8.1585388207021325",
    HEADERS = {
      "User-Agent"                => USER_AGENT,
      "Accept"                    => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Accept-Language"           => "en-US,en;q=0.5",
      "DNT"                       => "1",
      "Cookie"                    => "session=124.123.104.8.1585420925750331; session=25719682.5a1ef8cb90ec8",
      "Connection"                => "keep-alive",
      "Upgrade-Insecure-Requests" => "1",
      "Cache-Control"             => "max-age=0",
    }

    def self.save_chapter(tmp_path : String, chapter_id : String, add_bookmark = true)
      url = "https://muse.jhu.edu/chapter/#{chapter_id}"
      headers = HEADERS.merge({
        "Referer" => "https://muse.jhu.edu/verify?url=%2Fchapter%2F#{chapter_id}%2Fpdf",
      })

      begin
        Crest.get(url, max_redirects: 0, handle_errors: false, headers: headers) do |response|
          File.open("#{tmp_path}/chapter-#{chapter_id}.pdf", "w") do |file|
            IO.copy(response.body_io, file)
          end
        rescue e : Exception
          puts e.message
          raise e
          # We catch a temporary redirect
          # https://github.com/mamantoha/crest/blob/29a690726902c71884f9c80f0f9565256e74b7fd/src/crest/exceptions.cr#L20-L28
        end
      rescue e : Exception
        puts "FICK"
        raise e
      end
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
