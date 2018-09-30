require 'spec_helper'
require 'dashboard/dashboard_interactor'

describe DashboardInteractor do
  let(:repo) { Footprints::Repository }

  let(:confirmed_applicant)          { repo.applicant.create(name: "Confirmeded App", applied_on: Date.today, email: "test1@test.com",
                                                             assigned_craftsman: "A. Craftsman", craftsman_id: craftsman.id, has_steward: true,
                                                             discipline: "developer", skill: "resident", location: "Chicago") }
  let(:unconfirmed_applicant_one)    { repo.applicant.create(name: "Applicant One", applied_on: Date.today, email: "test2@test.com",
                                                             assigned_craftsman: "A. Craftsman", craftsman_id: craftsman.id, has_steward: false,
                                                             discipline: "developer", skill: "resident", location: "Chicago") }
  let(:unconfirmed_applicant_two)    { repo.applicant.create(name: "Applicant Two", applied_on: Date.today, email: "test3@test.com",
                                                             assigned_craftsman: "A. Craftsman", craftsman_id: craftsman.id, has_steward: false,
                                                             discipline: "developer", skill: "resident", location: "London") }
  let(:craftsman)                    { repo.craftsman.create(name: "A. Craftsman", employment_id: '123', email: 'testcraftsman@abcinc.com') }
  let(:craftsman_without_applicants) { repo.craftsman.create(name: "B. Craftsman", employment_id: '567', email: 'testcraftsman2@abcinc.com') }
  let(:interactor)                   { DashboardInteractor.new(repo.craftsman) }

  before :each do
    repo.assigned_craftsman_record.create({applicant_id: unconfirmed_applicant_one.id, craftsman_id: craftsman.id})
    repo.assigned_craftsman_record.create({applicant_id: unconfirmed_applicant_two.id, craftsman_id: craftsman.id})
    repo.assigned_craftsman_record.create({applicant_id: confirmed_applicant.id, craftsman_id: craftsman.id})
  end

  context '#confirmed_applicants' do
    it 'returns the confirmed applicants' do
      expect(interactor.confirmed_applicants(craftsman).first).to eq confirmed_applicant
    end
  end

  context '#not_yet_responded_applicants' do
    it 'returns the applicants that are waiting for response' do
      expect(interactor.not_yet_responded_applicants(craftsman).count).to eq 2
    end
  end

  context '#assign_steward_for_applicant' do
    it 'assigns the steward for an applicant' do
      interactor.assign_steward_for_applicant(unconfirmed_applicant_one)

      expect(unconfirmed_applicant_one.has_steward).to eq true
    end
  end

  context '#decline_applicant' do
    it 'declines an unconfirmed applicant' do
      interactor.decline_applicant(unconfirmed_applicant_one)

      expect(unconfirmed_applicant_one.assigned_craftsman).to eq nil
    end
  end

  context '#decline_all_applicants' do
    it 'declines all unconfirmed applicants' do
      interactor.decline_all_applicants(craftsman)

      expect(interactor.assigned_applicants(craftsman)).to eq []
    end

    it 'dispatches all applicants to new craftsmen after decline' do
      expect(interactor).to receive(:assign_new_craftsman).with(unconfirmed_applicant_one)
      expect(interactor).to receive(:assign_new_craftsman).with(unconfirmed_applicant_two)

      interactor.decline_all_applicants(craftsman)
    end

    it "sets the date until which the craftsman is unavailable for new applicants" do
      interactor.has_applicants?(craftsman)
      interactor.update_craftsman_availability_date(craftsman, Date.today + 1)

      expect(craftsman.unavailable_until).to eq(Date.today + 1)
    end

    it "does not set the Crasftman's unavailability if there are no applicants to decline" do
      interactor.update_craftsman_availability_date(craftsman, Date.today + 1)

      expect(craftsman_without_applicants.unavailable_until).to eq nil
    end
  end

  context '#decline_all_applicants_and_set_availability_date' do
    before(:each) do
      interactor.decline_all_applicants_and_set_availability_date(craftsman, Date.today + 1)
    end

    it 'sets the date' do
      expect(craftsman.unavailable_until).to eq(Date.today + 1)
    end

    it 'declines all applicants' do
      expect(interactor.assigned_applicants(craftsman)).to eq []
    end
  end
end
