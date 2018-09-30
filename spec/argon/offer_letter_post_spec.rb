require "spec_helper"
require 'argon/offer_letter_post.rb'

describe OfferLetterPost do
  it "gets a PDF from Argon" do
    json_data = '["document", {}, [ "paragraph", "Hello World!"]]'
    posting_service = double('posting_service').as_null_object
    argon_url = "https://argon.abcinc.com/api/pdf"
    params = {"api-key" => ENV['ARGON-API-KEY'], "piccup" => json_data}

    OfferLetterPost.get_pdf(json_data, posting_service)

    expect(posting_service).to have_received(:post).with(argon_url, body: params)
  end
end
