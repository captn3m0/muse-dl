require "process"

module Muse::Dl
  class Pdftk
    PDFTK_BINARY_NAME = "pdftk"
    @binary : String | Nil

    getter :binary

    def initialize
      @binary = Process.find_executable(Pdftk::PDFTK_BINARY_NAME)
      if !@binary
        puts "Could not find pdftk binary, exiting"
        Process.exit(1)
      end
    end
  end
end
