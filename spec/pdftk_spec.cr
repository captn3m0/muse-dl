require "./spec_helper"

describe Muse::Dl::Pdftk do
  it "should find pdftk binary" do
    pdftk = Muse::Dl::Pdftk.new
    pdftk.ready?.should eq true
  end
end
