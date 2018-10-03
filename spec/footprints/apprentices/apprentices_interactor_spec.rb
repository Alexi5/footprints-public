require 'warehouse/spec_helpers/employment_factory'
require 'spec_helper'
require 'apprentices/apprentices_interactor'

describe ApprenticesInteractor do 
  let(:mike) { Warehouse::SpecHelpers.create_employment({:id => 5, :first_name => "Mike",
                                                         :last_name => "Halpert",
                                                         :email => "jhalpert@dundermiffline.com",
                                                         :start => Date.today,
                                                         :end => Date.tomorrow,
                                                         :position_name => "Software Resident"})}

  let(:frank) { Warehouse::SpecHelpers.create_employment({:id => 5, :first_name => "Mike",
                                                          :last_name => "Halpert",
                                                          :email => "jhalpert@dundermiffline.com",
                                                          :start => Date.today,
                                                          :end => Date.tomorrow,
                                                          :position_name => "Not a Software Resident"})}

  let(:sarah) { Warehouse::SpecHelpers.create_employment({:id => 5, :first_name => "Sarah",
                                                          :last_name => "Halpert",
                                                          :email => "jhalpert@dundermiffline.com",
                                                          :start => 2.days.ago,
                                                          :end => 1.day.ago,
                                                          :position_name => "Software Resident"})}

  let(:bob_resident) { Warehouse::SpecHelpers.create_employment({:id=> 5, :first_name => "bob",            
                                                                :last_name => "Halpert",
                                                                :email => "jhalpert@dundermiffline.com",
                                                                :start => 4.days.ago,
                                                                :end => 3.day.ago,
                                                                :p_id => 1,
                                                                :position_name => "Software Resident"})}

  let(:bob_craft) { Warehouse::SpecHelpers.create_employment({:id => 6, :first_name => "bob",
                                                                   :last_name => "Halpert",
                                                                   :email => "jhalpert@dundermiffline.com",
                                                                   :start => 2.days.ago,
                                                                   :end => 1.day.ago,
                                                                   :p_id => 1,
                                                                   :position_name => "Software Craftsman"})}


  let(:interactor) { ApprenticesInteractor.new('fake_auth_token') }
  let(:employment_data)  { [
                            { :start => Time.parse("2014-09-01"),
                              :end => Time.parse("2015-09-30"),
                              :position => { :name => "UX Resident" },
                              :person_id => 33 }] }

  before :each do
    allow_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_employments).and_return(employment_data)
  end

  context '#fetch_all_residents' do
    it 'fetches all residents' do
      expect_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_employments).and_return([mike, sarah])
      expect(interactor.fetch_all_residents).to eq([mike])
    end
  end

  context '#fetch_all_students' do
    it 'fetches all current students' do
      old_student = {
        :skill_level => "student",
        :start => 2.days.ago,
        :end => 1.day.ago
      }
      new_student = {
        :skill_level => "student",
        :start => 2.days.ago,
        :end => 2.days.from_now
      }
      new_resident = {
        :skill_level => "resident",
        :start => 2.days.ago,
        :end => 2.days.from_now
      }
      allow_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_apprenticeships).and_return([new_student, old_student, new_resident])

      expect(interactor.fetch_all_students).to eq([new_student])
    end
  end

  context '#modify_resident_end_date' do
    it 'modifies an end date' do
      bob_resident[:end] = DateTime.new
      expect_any_instance_of(Warehouse::FakeAPI).to receive(:update_employment!).with(5, bob_resident)
      expect(interactor.modify_resident_end_date!(bob_resident, DateTime.new)).to eq(nil)
    end
  end

  context '#fetch_resident_by_employment_id' do
    it 'returns an employment if it is a valid resident' do
      allow_any_instance_of(Warehouse::FakeAPI).to receive(:find_employment_by_id).with(1).and_return(mike)
      expect(interactor.fetch_resident_by_id(1)).to eq(mike)
    end

    it 'does not return an employment if it is not a valid resident' do
      allow_any_instance_of(Warehouse::FakeAPI).to receive(:find_employment_by_id).with(1).and_return(frank)
      expect(interactor.fetch_resident_by_id(1)).to eq(ApprenticesInteractor::NoResident)
    end
  end

  context '#fetch_employment_by_person_id' do
    it 'returns corresponding craftsman' do
      expect_any_instance_of(Warehouse::FakeAPI).to receive(:find_all_employments).and_return([bob_resident, bob_craft])
      expect(interactor.fetch_corresponding_craftsman_employment(bob_resident)).to eq(bob_craft)
    end
  end
end
