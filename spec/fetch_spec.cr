require "./spec_helper"
# require "errors/muse_corrupt_pdf.cr"

describe Muse::Dl::Book do
  headers = {"Content-Type" => "text/html"}
  WebMock.stub(:get, "https://muse.jhu.edu/chapter/2379787/pdf")
    .to_return(body_io: File.new("spec/fixtures/chapter-2379787.html"), headers: headers)

  it "should notice the unable to construct chapter PDF error" do
    f = "/tmp/chapter-2379787.pdf"
    File.delete(f) if File.exists? f
    expect_raises Muse::Dl::Errors::MuseCorruptPDF do
      Muse::Dl::Fetch.save_chapter("/tmp", "2379787", "NA")
    end
  end
end
