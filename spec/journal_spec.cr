require "./spec_helper"

describe Muse::Dl::Journal do
  html = File.new("spec/fixtures/journal-159.html").gets_to_end
  j = Muse::Dl::Journal.new html

  it "it should parse the infobox for 159" do
    j.info["ISSN"].should eq "1530-7131"
    j.info["Print ISSN"].should eq "1531-2542"
    j.info["Coverage Statement"].should eq "Vol. 1 (2001) through current issue"
    j.info["Open Access"].should eq "No"
  end

  it "should parser summary" do
    j.summary.should eq <<-EOT
    Focusing on important research about the role of academic libraries and librarianship, portal also features commentary on issues in technology and publishing. Written for all those interested in the role of libraries within the academy, portal includes peer-reviewed articles addressing subjects such as library administration, information technology, and information policy. In its inaugural year, portal earned recognition as the runner-up for best new journal, awarded by the Council of Editors of Learned Journals (CELJ). An article in  portal, "Master's and Doctoral Thesis Citations: Analysis and Trends of a Longitudinal Study," won the Jesse H. Shera Award for Distinguished Published Research from the Library Research Round Table of the American Library Association.
    EOT
  end

  it "should parse publisher" do
    j.publisher.should eq "Johns Hopkins University Press"
  end

  it "should return issues" do
    j.issues[0].id.should eq "41793"
    j.issues[-1].id.should eq "1578"
  end
end
