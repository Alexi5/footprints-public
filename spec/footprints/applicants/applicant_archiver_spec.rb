require 'spec_helper'
require 'applicants/applicant_archiver'

describe Footprints::ApplicantArchiver do

  let!(:a_applicant) { Footprints::Repository.applicant.create(:name => "A Applicant", :applied_on => DateTime.current, :archived => true,
                                                               :discipline => "developer", :skill => "resident", :location => "Chicago") }
  let!(:b_applicant) { Footprints::Repository.applicant.create(:name => "B Applicant", :applied_on => DateTime.current - 3.months,
                                                               :discipline => "developer", :skill => "resident", :location => "Chicago") }
  let!(:c_applicant) { Footprints::Repository.applicant.create(:name => "C Applicant", :applied_on => DateTime.current,
                                                               :discipline => "developer", :skill => "resident", :location => "Chicago") }

  it "archives applicants that are outstanding for three months" do
    Footprints::ApplicantArchiver.archive_neglected_applicants
    expect(Applicant.find_by_name("A Applicant").archived).to be_true
    expect(Applicant.find_by_name("B Applicant").archived).to be_true
    expect(Applicant.find_by_name("C Applicant").archived).to be_false
  end

end
