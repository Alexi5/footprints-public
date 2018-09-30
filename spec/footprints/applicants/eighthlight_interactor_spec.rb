require 'spec_helper'
require 'applicants/eighthlight_applicants_interactor'

describe EighthlightApplicantsInteractor do
  let(:repo)   { Footprints::Repository }
  let(:params) { {:discipline        => "developer",
                  :location          => "Chicago",
                  :name              => "Tes Teroo",
                  :email             => "tes@teroo.com",
                  :url               => "http://my.blog.com",
                  :about             => "Once upon a time...",
                  :software_interest => "Making stuff is cool.",
                  :skill             => "student",
                  :reason            => "I'm hungry for knowledge",
                  :applied_on        => "2014-04-29T01:52:45Z"} }

  describe "#apply" do
    it "should return 200 OK when given complete params" do
      status, body = described_class.apply(params)
      expect(status).to eq(200)
      expect(body).to be_nil
    end

    it "should return 422 Duplicate Applicant if applicant already exists" do
      repo.applicant.create(:name => "First", :applied_on => Date.yesterday, :email => "tes@teroo.com", :discipline => "developer",
                            :location => "Chicago", :skill => "student")
      status, body = described_class.apply(params)
      expect(status).to eq(422)
      expect(body).to eq("Duplicate Applicant")
    end

    it "should return 400 if invalid applicant" do
      params.delete(:name)
      status, body = described_class.apply(params)
      expect(status).to eq(400)
      expect(body).to eq("Name can't be blank")
    end
  end
end
