require "crest"

module Muse::Dl
  class Fetch
    def get_info(url : String) : (Muse::Dl::Book | Muse::Dl::Issue)
      match = /https:\/\/muse.jhu.edu\/(book|journal)\/(\d+)/.match url
      if match
        begin
          response = Crest.get url
        rescue ex : Crest::NotFound
          raise Muse::Dl::InvalidLink
        end
      else
        raise Muse::Dl::InvalidLink
      end
    end
  end
end
