require "./parser.cr"
require "./pdftk.cr"
require "./fetch.cr"
require "./book.cr"

# require "./journal.cr"

# TODO: Write documentation for `Muse::Dl`
module Muse::Dl
  VERSION = "0.1.0"

  # TODO: Put your code here
  class Main
    def self.run(args : Array(String))
      parser = Parser.new(args)
      Fetch.get_info(parser.url)
    end
  end
end

Muse::Dl::Main.run(ARGV)
