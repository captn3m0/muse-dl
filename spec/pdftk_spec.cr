require "./spec_helper"

describe Muse::Dl::Pdftk do
  it "should find pdftk binary" do
    pdftk = Muse::Dl::Pdftk.new
    if pdftk.binary
      pdftk.binary.should eq "/usr/sbin/pdftk"
    end
  end
end
