require "./spec_helper"

describe Muse::Dl::Book do
  html = File.new("spec/fixtures/book-875.html").gets_to_end
  book = Muse::Dl::Book.new html

  it "it should parse the infobox for 875" do
    book.info["ISBN"].should eq "9780813928517"
    book.info["Related ISBN"].should eq "9780813928456"
    book.info["OCLC"].should eq "755633557"
    book.info["Pages"].should eq "432"
    book.info["Launched on MUSE"].should eq "2012-01-01"
    book.info["Language"].should eq "English"
    book.info["Open Access"].should eq "No"

    book.title.should eq "Accommodating Revolutions: Virginia's Northern Neck in an Era of Transformations, 1760-1810"
    book.author.should eq "Albert H. Tillson, Jr."
    book.date.should eq "2010"
    book.publisher.should eq "University of Virginia Press"
    book.formats.should contain :pdf
    book.formats.should_not contain :html
  end

  it "should parse the summary" do
    book.summary.should eq "Accommodating Revolutions addresses a controversy of long standing among historians of eighteenth-century America and Virginia—the extent to which internal conflict and/or consensus characterized the society of the Revolutionary era. In particular, it emphasizes the complex and often self-defeating actions and decisions of dissidents and other non-elite groups. By focusing on a small but significant region, Tillson elucidates the multiple and interrelated sources of conflict that beset Revolutionary Virginia, but also explains why in the end so little changed."
    book.summary_html.should eq "<u>Accommodating Revolutions </u>addresses a controversy of long standing among historians of eighteenth-century America and Virginia—the extent to which internal conflict and/or consensus characterized the society of the Revolutionary era. In particular, it emphasizes the complex and often self-defeating actions and decisions of dissidents and other non-elite groups. By focusing on a small but significant region, Tillson elucidates the multiple and interrelated sources of conflict that beset Revolutionary Virginia, but also explains why in the end so little changed."
  end

  it "should parse the cover" do
    book.cover_url.should eq "https://muse.jhu.edu/book/875/image/front_cover.jpg"
    book.thumbnail_url.should eq "https://muse.jhu.edu/book/875/image/front_cover.jpg?format=180"
  end

  it "should parse the chapters" do
    book.chapters.should eq [
      ["16872", "Cover"],
      ["16873", "Title Page"],
      ["16874", "Copyright Page"],
      ["16875", "Table of Contents"],
      ["16876", "Acknowledgments"],
      ["16877", "Introduction"],
      ["16878", "Chapter 1: A Troubled Gentry"],
      ["16879", "Chapter 2: Beyond the Plantations"],
      ["16880", "Chapter 3: The World(s) Northern Neck Slavery Made"],
      ["16881", "Chapter 4: The Scottish Merchants\n"],
      ["16882", "Chapter 5: Controlling the Revolution\n"],
      ["16883", "Chapter 6: The Evangelical Challenge"],
      ["16884", "Chapter 7: The Preservation of Hegemony"],
      ["16885", "Notes"],
      ["16886", "Bibliography"],
      ["16887", "Index"],
    ]
  end

  it "should parse book/68534" do
    html = File.new("spec/fixtures/book-68534.html").gets_to_end
    book = Muse::Dl::Book.new html
    book.info["ISBN"].should eq "9781501737695"
    book.info["Related ISBN"].should eq "9781501742583"
    book.info["OCLC"].should eq "1122613406"
    book.info["Launched on MUSE"].should eq "2019-10-10"
    book.info["Language"].should eq "English"
    book.info["Open Access"].should eq "Yes"
    book.info["DOI"].should eq "10.1353/book.68534"
    book.formats.should contain :html
    book.formats.should_not contain :pdf
  end

  it "should note both formats for book/60322" do
    html = File.new("spec/fixtures/book-60322.html").gets_to_end
    book = Muse::Dl::Book.new html
    book.formats.should contain :pdf
    book.formats.should contain :html
  end

  it "should note both formats for book/57833" do
    html = File.new("spec/fixtures/book-57833.html").gets_to_end
    book = Muse::Dl::Book.new html
    book.formats.should contain :pdf
  end
end
