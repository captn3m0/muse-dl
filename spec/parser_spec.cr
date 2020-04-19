require "./spec_helper"

describe Muse::Dl::Parser do
  it "should parse options" do
    parser = Muse::Dl::Parser.new(["--no-bookmarks", "--tmp-dir", "/tmp", "--no-cleanup", "--output", "file.pdf", "https://muse.jhu.edu/book/68534"])
    parser.bookmarks.should eq false
    parser.tmp.should eq "/tmp"
    parser.cleanup.should eq false
    parser.output.should eq "file.pdf"
  end

  it "should have reasonable defaults" do
    parser = Muse::Dl::Parser.new(["https://muse.jhu.edu/book/68534"])
    parser.bookmarks.should eq true
    parser.cleanup.should eq true
    parser.output.should eq "tempfilename.pdf"
    parser.url.should eq "https://muse.jhu.edu/book/68534"
  end
end
