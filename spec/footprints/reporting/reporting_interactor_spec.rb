require 'spec_helper'
require 'warehouse/fake_api'
require 'reporting/reporting_interactor'
require 'warehouse/json_api'

describe ReportingInteractor do
  let(:interactor) { ReportingInteractor.new('fake_auth_token') }
  let(:employment_data)  { [{ :start => Time.parse("2014-08-01"), :end => Time.parse("2014-08-30"), :position => { :name => "Software Craftsman" }, :person_id => 30 },
                            { :start => Time.parse("2014-08-01"), :end => Time.parse("2015-08-30"), :position => { :name => "UX Craftsman" }, :person_id => 28 },
                            { :start => Time.parse("2014-10-01"), :end => Time.parse("2014-10-30"), :position => { :name => "UX Craftsman" }, :person_id => 29 },
                            { :start => Time.parse("2015-08-01"), :end => Time.parse("2015-08-30"), :position => { :name => "Software Craftsman" }, :person_id => 31 },
                            { :start => Time.parse("2014-09-01"), :end => Time.parse("2014-12-30"), :position => { :name => "Software Resident" }, :person_id => 32 },
                            { :start => Time.parse("2014-12-31"), :end => Time.parse("2016-12-30"), :position => { :name => "Software Craftsman" }, :person_id => 32 },
                            { :start => Time.parse("2014-09-01"), :end => Time.parse("2015-09-30"), :position => { :name => "UX Resident" }, :person_id => 33 }] }

  before :each do
    allow_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_employments).and_return(employment_data)
  end

  context '#fetch_all_apprenticeships' do
    it "fetches all apprenticeships from warehouse" do
      expect_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_apprenticeships)
      interactor.fetch_all_apprenticeships
    end
  end

  context '#fetch_all_employments' do
    it 'fetches all employments' do
      expect_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_employments)
      interactor.fetch_all_employments
    end
  end

  context '#fetch_projection_data' do
    xit 'fetches the data for a projection of one year' do
      expect(interactor.fetch_projection_data(8, 2014)).to eq({
        "Aug 2014" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 0,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Sep 2014" => {
          "Software Craftsmen" => 0, "UX Craftsmen" => 1,
          "Software Residents" => 1, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Oct 2014" => {
          "Software Craftsmen" => 0, "UX Craftsmen" => 2,
          "Software Residents" => 1, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Nov 2014" => {
          "Software Craftsmen" => 0, "UX Craftsmen" => 1,
          "Software Residents" => 1, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Dec 2014" => {
          "Software Craftsmen" => 0, "UX Craftsmen" => 1,
          "Software Residents" => 1, "UX Residents" => 1,
          "Finishing Software Residents" => 1, "Finishing UX Residents" => 0,
          "Student Apprentices" => 1
        },
        "Jan 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Feb 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Mar 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Apr 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "May 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Jun 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Jul 2015" => {
          "Software Craftsmen" => 1, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        },
        "Aug 2015" => {
          "Software Craftsmen" => 2, "UX Craftsmen" => 1,
          "Software Residents" => 0, "UX Residents" => 1,
          "Finishing Software Residents" => 0, "Finishing UX Residents" => 0,
          "Student Apprentices" => 0
        }
      })
    end
  end

  context 'authentication' do
    it 'raises an exception' do
      allow_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_employments).and_raise(Warehouse::AuthenticationError.new([]))

      expect{ interactor.fetch_all_employments }.to raise_error(ReportingInteractor::AuthenticationError)
    end
  end
end
