require "../src/util"
require "./spec_helper"

describe Muse::Dl::Util do
  it "should sanitize filenames properly" do
    fn = Muse::Dl::Util.slug_filename("Hello world - \" :A$3, a story; a poem|chapter")
    fn.should eq "Hello world - - -A-3, a story- a poem-chapter"
  end
end
