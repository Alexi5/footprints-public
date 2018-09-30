require "spec_helper"
require "applicants/applicant_index_presenter"

describe ApplicantIndexPresenter do

  describe "#waiting_state_class" do
    it "returns our-court if applicant is waiting on action from us" do
      applicant = Footprints::Repository.applicant.create({:name => "A Applicant", :applied_on => DateTime.current, :discipline => "developer",
                                                           :skill => "resident", :location => "Chicago"})
      presenter = ApplicantIndexPresenter.new(applicant)
      expect(presenter.waiting_state_class(applicant)).to eq "exclamation"
    end

    it "returns their-court we are waiting on action from applicant" do
      applicant = Footprints::Repository.applicant.create({:name => "A Applicant", :applied_on => DateTime.current, :initial_reply_on => DateTime.current,
                                                           :discipline => "developer", :skill => "resident", :location => "Chicago"})
      presenter = ApplicantIndexPresenter.new(applicant)
      expect(presenter.waiting_state_class(applicant)).to eq "clock-o"
    end

    it "returns archived if applicant is archived" do
      applicant = Footprints::Repository.applicant.create({:name => "A Applicant", :applied_on => DateTime.current, :archived => true, :discipline => "developer",
                                                           :skill => "resident", :location => "Chicago"})
      presenter = ApplicantIndexPresenter.new(applicant)
      expect(presenter.waiting_state_class(applicant)).to eq "folder-open-o"
    end
  end
end
