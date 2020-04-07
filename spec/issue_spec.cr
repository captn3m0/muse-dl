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

  # it "should parser summary" do
  #   issue.summary.should eq <<-EOT
  #   Focusing on important research about the role of academic libraries and librarianship, portal also features commentary on issues in technology and publishing. Written for all those interested in the role of libraries within the academy, portal includes peer-reviewed articles addressing subjects such as library administration, information technology, and information policy. In its inaugural year, portal earned recognition as the runner-up for best new journal, awarded by the Council of Editors of Learned Journals (CELJ). An article in  portal, "Master's and Doctoral Thesis Citations: Analysis and Trends of a Longitudinal Study," won the Jesse H. Shera Award for Distinguished Published Research from the Library Research Round Table of the American Library Association.
  #   EOT
  # end

  it "should parse publisher" do
    issue.publisher.should eq "Johns Hopkins University Press"
  end
end
