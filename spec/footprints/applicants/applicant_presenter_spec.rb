require 'spec_helper'
require "applicants/applicant_presenter"
require 'date'

describe ApplicantPresenter do 
  let (:test_applicant1) { Footprints::Repository.applicant.create({:name => "Erykah Badu",    :applied_on => Date.parse("20140101")}) }
  let (:test_applicant2) { Footprints::Repository.applicant.create({:name => "Billie Holiday", :applied_on => Date.parse("20120101")}) }
  let (:test_applicants) { [test_applicant1, test_applicant2] }
  let (:test_presenter ) { ApplicantPresenter.new(test_applicants) }


  it "sorts applicants by date" do   
    ordered_applicants = test_presenter.sort_by_date(test_applicants)

    expect(ordered_applicants.first.name).to eq("Billie Holiday")
  end

  it "returns the number of days since last applied" do 
    expect(test_presenter.days_since_last_applied(Date.today - 365)).to eq(365)
  end

  it "knows the number of applicants" do
    expect(test_presenter.applicant_count).to eq(2)
  end

  it "knows whether there are any applicants" do
    expect(test_presenter.has_applicants?).to eq(true)
  end
end
