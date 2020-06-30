require "./infoparser.cr"
require "./issue.cr"

module Muse::Dl
  class Article
    @id : String

    def initialize(id : String)
      @id = id
      @url = "https://muse.jhu.edu/article/#{id}"
    end
  end
end
