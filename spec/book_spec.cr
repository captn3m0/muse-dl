require "./spec_helper"

describe Muse::Dl::Book do
  it "it should parse the infobox" do
    html = <<-EOT
    <div class="column full">
    <div class="title_wrap details">
      <h2>Additional Information</h2>
    </div>
    <div class="details_tbl">
      <div class="details_row">
        <div class="cell label">
          ISBN
        </div>
        <div class="cell">
          9780813928517
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          Related ISBN
        </div>
        <div class="cell">
          9780813928456
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          MARC Record
        </div>
        <div class="cell">
          <a href="https://about.muse.jhu.edu/lib/metadata?filename=muse_book_875&amp;no_auth=1&amp;format=marc&amp;content_ids=book:875">Download</a>
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          OCLC
        </div>
        <div class="cell">
          755633557
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          Pages
        </div>
        <div class="cell">
          432
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          Launched on MUSE
        </div>
        <div class="cell">
          2012-01-01
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          DOI
        </div>
        <div class="cell">
          <a href="https://doi.org/10.1353/book.68534" target="_blank">10.1353/book.68534<img src="/images/link_blue.png" alt="external link" style="vertical-align:top;"></a>
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          Language
        </div>
        <div class="cell">
          English
        </div>
      </div>
      <div class="details_row">
        <div class="cell label">
          Open Access
        </div>
        <div class="cell">
          No
        </div>
      </div>
    </div>
  </div>
EOT
    book = Muse::Dl::Book.new html
    book.info["ISBN"].should eq "9780813928517"
    book.info["Related ISBN"].should eq "9780813928456"
    book.info["OCLC"].should eq "755633557"
    book.info["Pages"].should eq "432"
    book.info["Launched on MUSE"].should eq "2012-01-01"
    book.info["Language"].should eq "English"
    book.info["Open Access"].should eq "No"
    book.info["DOI"].should eq "10.1353/book.68534"
  end
end
