require "./infoparser.cr"
require "./issue.cr"

module Muse::Dl
  class Article
    getter id : String
    setter title : String | Nil, start_page : Int32 | Nil, end_page : Int32 | Nil

    def initialize(id : String)
      @id = id
      @url = "https://muse.jhu.edu/article/#{id}"
    end
  end
end
