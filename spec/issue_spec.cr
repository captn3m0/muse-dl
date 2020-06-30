require "../src/issue"
require "./spec_helper"
require "webmock"

describe Muse::Dl::Issue do
  WebMock.stub(:get, "https://muse.jhu.edu/issue/41793")
    .to_return(body: File.new("spec/fixtures/issue-41793.html").gets_to_end)

  issue = Muse::Dl::Issue.new "41793"
  issue.parse

  it "should initialize correctly" do
    issue.id.should eq "41793"
    issue.url.should eq "https://muse.jhu.edu/issue/41793"
  end

  it "should parse info correctly" do
    issue.info["ISSN"].should eq "1530-7131"
    issue.info["Print ISSN"].should eq "1531-2542"
    issue.info["Launched on MUSE"].should eq "2020-02-05"
    issue.info["Open Access"].should eq "No"
    issue.title.should eq "Volume 20, Number 1, January 2020"
  end

  it "should parse title correctly" do
    issue.volume.should eq "20"
    issue.number.should eq "1"
    issue.date.should eq "January 2020"
  end

  it "should parser summary" do
    issue.summary.should eq <<-EOT
    Focusing on important research about the role of academic libraries and librarianship, portal also features commentary on issues in technology and publishing. Written for all those interested in the role of libraries within the academy, portal includes peer-reviewed articles addressing subjects such as library administration, information technology, and information policy. In its inaugural year, portal earned recognition as the runner-up for best new journal, awarded by the Council of Editors of Learned Journals (CELJ). An article in  portal, "Master's and Doctoral Thesis Citations: Analysis and Trends of a Longitudinal Study," won the Jesse H. Shera Award for Distinguished Published Research from the Library Research Round Table of the American Library Association.
    EOT
  end

  it "should parse publisher" do
    issue.publisher.should eq "Johns Hopkins University Press"
  end
  it "should parse the journal title" do
    issue.journal_title.should eq "portal: Libraries and the Academy"
  end

  it "should parse non-numbered issues" do
    WebMock.stub(:get, "https://muse.jhu.edu/issue/35852")
      .to_return(body: File.new("spec/fixtures/issue-35852.html").gets_to_end)
    issue = Muse::Dl::Issue.new "35852"
    issue.parse

    issue.volume.should eq "1"
    issue.number.should eq "2"
    issue.date.should eq "2016"

    issue.info["ISSN"].should eq "2474-9419"
    issue.info["Print ISSN"].should eq "2474-9427"
    issue.info["Launched on MUSE"].should eq "2017-02-21"
    issue.info["Open Access"].should eq "Yes"
    issue.title.should eq "Volume 1, Issue 2, 2016"
    issue.journal_title.should eq "Constitutional Studies"

    expected_pages = [
      [1, 22],
      [23, 40],
      [41, 58],
      [59, 80],
      [81, 95],
      [97, 116],
    ]

    expected_titles = [
      "The Limits of Veneration: Public Support for a New Constitutional Convention",
      "Secession and Nullification as a Global Trend",
      "Challenging Constitutionalism in Post-Apartheid South Africa",
      "Democracy by Lawsuit: Or, Can Litigation Alleviate the European Union’s “Democratic Deficit?”",
      "Private Enforcement of Constitutional Guarantees in the Ku Klux Act of 1871",
      "Sober Second Thoughts: Evaluating the History of Horizontal Judicial Review by the U.S. Supreme Court",
    ]

    issue.articles.each_with_index do |a, i|
      a.start_page.should eq expected_pages[i][0]
      a.end_page.should eq expected_pages[i][1]
      a.title.should eq expected_titles[i]
    end
  end
end
