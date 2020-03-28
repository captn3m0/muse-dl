require "crest"
require "./errors/*"

module Muse::Dl
  class Fetch
    def self.get_info(url : String) : (Muse::Dl::Book | Muse::Dl::Journal)
      match = /https:\/\/muse.jhu.edu\/(book|journal)\/(\d+)/.match url
      if match
        begin
          response = Crest.get url
          case match[1]
          when "book"
            return Muse::Dl::Book.new response
          when "journal"
            return Muse::Dl::Journal.new response
          end
        rescue ex : Crest::NotFound
          raise Muse::Dl::Errors::InvalidLink
        end
      else
        raise Muse::Dl::Errors::InvalidLink
      end
    end
  end
end
