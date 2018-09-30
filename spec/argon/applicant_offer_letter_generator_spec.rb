# encoding: utf-8
require 'spec_helper'
require 'argon/applicant_offer_letter_generator.rb'

describe ApplicantOfferLetterGenerator do
  let!(:craftsman) { Footprints::Repository.craftsman.create(:name => "A Craftsman", :employment_id => "007") }
  let!(:applicant) { Footprints::Repository.applicant.create(:name => "G Applicant",
                                                             :assigned_craftsman => "A Craftsman",
                                                             :email => "g.applicant@example.com",
                                                             :applied_on => Date.today,
                                                             :initial_reply_on => Date.today,
                                                             :sent_challenge_on => Date.today,
                                                             :completed_challenge_on => Date.today,
                                                             :reviewed_on => Date.today,
                                                             :resubmitted_challenge_on => Date.today,
                                                             :decision_made_on => Date.today,
                                                             :hired => "yes",
                                                             :discipline => "developer",
                                                             :start_date => "6/21/2014".to_date,
                                                             :end_date => "10/26/2014".to_date,
                                                             :mentor => "A Craftsman",
                                                             :skill => "resident",
                                                             :location => "London")}

  let(:params) { {:duration => "4",
                  :start_date => "6/21/2014",
                  :pt_ft => "full time",
                  :hours_per_week => "37.5",
                  :withdraw_offer_date => "6/25/2014"} }


  let!(:generator) { ApplicantOfferLetterGenerator.new(applicant, params) }

  def add_test_salaries
    Footprints::Repository.monthly_apprentice_salary.create({location: applicant.location, duration: 4, amount: 500.0})
    Footprints::Repository.annual_starting_craftsman_salary.create({location: applicant.location, amount: 12345.0})
  end

  before :each do
    add_test_salaries
  end

  after :each do
    Footprints::Repository.monthly_apprentice_salary.destroy_all
    Footprints::Repository.annual_starting_craftsman_salary.destroy_all
  end

  it "generates a link to Argon with the JSON data and API key" do
    allow(generator).to receive(:get_template).and_return(File.new("#{Rails.root}/spec/argon/mock_offer_letter_template.json"))

    expect(generator.build_offer_letter_as_json).to eq('[ "document", {}, [ "paragraph", {}, "Name is G Applicant, residency length is 4 months, start date is 21 June 2014, apprentice salary is £500.00 per month, craftsman salary is £12,345.00 per year, mentor name is A Craftsman, pt/ft is full time, hours per week is 37.5, withdraw offer date is 25 June 2014" ]]')
  end
end
