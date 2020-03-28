require "./spec_helper"

describe Muse::Dl::Parser do
  it "should parse options" do
    parser = Muse::Dl::Parser.new(["--no-bookmarks", "--tmp-dir", "/tmp", "--no-cleanup", "--output", "file.pdf"])
    parser.bookmarks.should eq false
    parser.tmp.should eq "/tmp"
    parser.cleanup.should eq false
    parser.output.should eq "file.pdf"
  end

  it "should have reasonable defaults" do
    parser = Muse::Dl::Parser.new
    parser.bookmarks.should eq true
    parser.cleanup.should eq true
    parser.tmp.should eq "/tmp"
    parser.output.should eq "tempfilename.pdf"
  end
end
