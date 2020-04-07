module Muse::Dl
  class Util
    # Generates a safe filename
    def self.slug_filename(input : String)
      input.strip.tr("\u{202E}%$|:;/\"\t\r\n\\", "-")
    end
  end
end
