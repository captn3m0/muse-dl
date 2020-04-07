require "./thing.cr"

module Muse::Dl
  class Issue
    @id : String

    getter :id

    def initialize(id : String)
      @id = id
    end
  end
end
