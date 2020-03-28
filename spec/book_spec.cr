require "./spec_helper"

describe Muse::Dl::Book do
  it "it should parse the infobox for 875" do
    html = File.new("spec/fixtures/book-875.html").gets_to_end
    book = Muse::Dl::Book.new html
    book.info["ISBN"].should eq "9780813928517"
    book.info["Related ISBN"].should eq "9780813928456"
    book.info["OCLC"].should eq "755633557"
    book.info["Pages"].should eq "432"
    book.info["Launched on MUSE"].should eq "2012-01-01"
    book.info["Language"].should eq "English"
    book.info["Open Access"].should eq "No"
  end

  it "it should parse the DOI for 68534" do
    html = File.new("spec/fixtures/book-68534.html").gets_to_end
    book = Muse::Dl::Book.new html
    book.info["ISBN"].should eq "9781501737695"
    book.info["Related ISBN"].should eq "9781501742583"
    book.info["OCLC"].should eq "1122613406"
    book.info["Launched on MUSE"].should eq "2019-10-10"
    book.info["Language"].should eq "English"
    book.info["Open Access"].should eq "Yes"
    book.info["DOI"].should eq "10.1353/book.68534"
  end
end
