require 'spec_helper'
require 'applicants/applicant_interactor.rb'

describe ApplicantInteractor do
  let!(:craftsman) { Footprints::Repository.craftsman.create(:name => "A Craftsman", :employment_id => "007", :email => "acraftsman@example.com") }
  let!(:bcraftsman) { Footprints::Repository.craftsman.create(:name => "B Craftsman", :employment_id => "008", :email => "bcraftsman@example.com") }
  let!(:applicant) { Footprints::Repository.applicant.create(:name => "Bob", :applied_on => Date.current, :email => "test@test.com", :location => "Chicago",
                                                             :skill => "student", :discipline => "sofware") }

  describe "#update" do
    it "updates the applicant" do
      params = { :name => "John" }
      ApplicantInteractor.new(applicant, params).update
      expect(applicant.name).to eq("John")
    end
  end

  describe "#update_applicant_for_hiring" do
    before :each do
      params = { mentor: "A Craftsman", start_date: Date.today, end_date: Date.today + 10 }
      ApplicantInteractor.new(applicant, params).update_applicant_for_hiring
    end

    it "updates the applicant's decision_on date" do
      expect(applicant.decision_made_on).to eq(Date.today)
    end

    it "updates the applicant's decision_on date" do
      expect(applicant.hired).to eq("yes")
    end
  end

  describe "#craftsman_changed?" do
    context "craftsman has changed" do
      it "recognizes that assigned craftsman has changed" do
        applicant.assigned_craftsman = "B Craftsman"
        interactor = ApplicantInteractor.new(applicant, :assigned_craftsman => "A Craftsman")
        expect(interactor.craftsman_changed?).to be_true
      end
    end

    context "craftsman has not changed" do
      it "returns false if craftsman changes from nil to empty string" do
        expect(applicant.assigned_craftsman).to be_nil
        interactor = ApplicantInteractor.new(applicant, :assigned_craftsman => "")
        expect(interactor.craftsman_changed?).to be_false
      end

      it "returns false if craftsman has not changed" do
        applicant.update_attribute(:assigned_craftsman, "A Craftsman")
        interactor = ApplicantInteractor.new(applicant, :assigned_craftsman => "A Craftsman")
        applicant.assigned_craftsman = "A Craftsman"
        expect(interactor.craftsman_changed?).to be_false
      end
    end
  end

  describe "#notify_if_craftsman_changed" do
    context "initial craftsman assigned" do
      it "calls send_request_email" do
        applicant.assigned_craftsman = "A Craftsman"
        interactor = ApplicantInteractor.new(applicant, {})
        allow(interactor).to receive(:send_request_email)
        allow(interactor).to receive(:send_transfer_email)
        interactor.notify_if_craftsman_changed
        expect(interactor).to have_received(:send_request_email)
        expect(interactor).to_not have_received(:send_transfer_email)
      end
    end

    context "craftsman has not changed" do
      it "doesn't call send request email" do
        params = {:assigned_craftsman => applicant.assigned_craftsman}
        interactor = ApplicantInteractor.new(applicant, params)
        interactor.notify_if_craftsman_changed
        expect(interactor).to_not receive(:send_request_email)
      end
    end

    context "applicant transfered to another craftsman" do
      it "calls send_transfer_email" do
        applicant.update_attributes(:assigned_craftsman => "A Craftsman", :has_steward => true)
        applicant.assigned_craftsman = "B Craftsman"
        params = { :assigned_craftsman => "B Craftsman"}
        interactor = ApplicantInteractor.new(applicant, params)
        allow(interactor).to receive(:send_transfer_emails)
        interactor.notify_if_craftsman_changed
        expect(interactor).to have_received(:send_transfer_emails)
      end

      it "sends transfer email to correct craftsman" do
        ActionMailer::Base.deliveries = []
        applicant.update_attributes(:assigned_craftsman => "A Craftsman", :has_steward => true)
        params = { :assigned_craftsman => "B Craftsman"}
        interactor = ApplicantInteractor.new(applicant, params)
        interactor.update
        mail = ActionMailer::Base.deliveries
        expect(mail.count).to eq(2)
        expect(mail.first.to).to eq(["acraftsman@example.com"])
        expect(mail.last.to).to eq(["bcraftsman@example.com"])
      end

    end

    context "applicant has not been transfered" do
      it "doesn't call send_transfer_email" do
        params = {:assigned_craftsman => applicant.assigned_craftsman}
        interactor = ApplicantInteractor.new(applicant, params)
        allow(interactor).to receive(:send_transfer_email)
        interactor.notify_if_craftsman_changed
        expect(interactor).to_not have_received(:send_transfer_email)
      end
    end

    context "invalid update information" do
      it "doesn't send email to craftsman if update invalid" do
        params = {:name => "", :assigned_craftsman => "A Craftsman"}
        interactor = ApplicantInteractor.new(applicant, params)
        allow(interactor).to receive(:send_request_email)
        applicant.assign_attributes(params)
        expect { interactor.update }.to raise_error ActiveRecord::RecordInvalid
        expect(interactor).not_to have_received(:send_request_email)
      end
    end

    context "archiving an applicant" do
      it "archives an applicant if the checkbox is selected" do
        params = {:archived => "on"}
        interactor = ApplicantInteractor.new(applicant, params)
        allow(interactor).to receive(:send_request_email)
        interactor.update
        expect(applicant.reload.archived).to be_true
      end

      it "unarchives an applicant if the checkbox is empty" do
        params = {:archived => "off"}
        interactor = ApplicantInteractor.new(applicant, params)
        allow(interactor).to receive(:send_request_email)
        interactor.update
        expect(applicant.reload.archived).to be_false
      end
    end
  end

  describe "#notify_if_decision_made" do
    let!(:applicant) { Footprints::Repository.applicant.create(:name => "Bill", :applied_on => Date.current,
                                                               :email => "test@example.com", :craftsman_id => craftsman.id,
                                                               :assigned_craftsman => "A Craftsman", :has_steward => true,
                                                               :discipline => "developer", :skill => "resident", :location => "Chicago") }

    before :each do
      ActionMailer::Base.deliveries = []
      allow_any_instance_of(ApplicantInteractor).to receive(:setup_warehouse_api) { double.as_null_object }
    end

    context "applicant hired" do
      it "notifies craftsman when an applicant is hired" do
        params = { :decision_made_on => Date.today, :hired => "yes", :start_date => Date.today, :end_date => Date.tomorrow, :mentor => "A Craftsman" }
        interactor = ApplicantInteractor.new(applicant, params)
        interactor.update
        mail = ActionMailer::Base.deliveries
        expect(mail.count).to eq(1)
        expect(mail.first.subject).to eq "[Footprints] A decision has been made on applicant #{applicant.name}"
        expect(mail.first.to).to include ENV["ADMIN_EMAIL"]
      end

      it "doesn't notify craftsman if hired was not set on current update" do
        applicant.update_attributes(:decision_made_on => Date.today, :hired => "yes", :start_date => Date.today, :end_date => Date.tomorrow, :mentor => "A Craftsman")
        ActionMailer::Base.deliveries = []
        interactor = ApplicantInteractor.new(applicant, {})
        interactor.update
        mail = ActionMailer::Base.deliveries
        expect(mail).to be_empty
      end
    end

    context "applicant not hired" do
      it "doesn't notify craftsman if decision has not been made" do
        interactor = ApplicantInteractor.new(applicant, {})
        interactor.update
        mail = ActionMailer::Base.deliveries
        expect(mail).to be_empty
      end

      it "doesn't notify craftsman if applicant was not hired" do
        params = { :decision_made_on => DateTime.current, :hired => "no" }
        interactor = ApplicantInteractor.new(applicant, params)
        interactor.update
        mail = ActionMailer::Base.deliveries
        expect(mail).to be_empty
      end
    end
  end

  describe "#send_to_warehouse_if_hired" do

    let!(:applicant) { 
      Footprints::Repository.applicant.create(
        :name => "Bill", 
        :applied_on => Date.current, 
        :email => "test@example.com",
        :craftsman_id => craftsman.id, 
        :assigned_craftsman => "A Craftsman",
        :has_steward => true, 
        :discipline => "developer", 
        :skill => "student",
        :location => "Chicago") }

    it "sends apprentices to warehouse if they are hired" do
      applicant.assign_attributes(:decision_made_on => Date.today,
                                  :hired => "yes",
                                  :start_date => Date.today,
                                  :end_date => Date.tomorrow,
                                  :mentor => "A Craftsman",
                                  :skill => "resident")
      api = double("warehouse_api").as_null_object
      allow_any_instance_of(ApplicantInteractor).to receive(:setup_warehouse_api) { api }
      interactor = ApplicantInteractor.new(applicant, {})
      interactor.update
      expect(api).to have_received(:add_resident!)
    end

    it "sends student apprentices to warehouse if they are hired" do
      applicant.assign_attributes(:decision_made_on => Date.today,
                                  :hired => "yes",
                                  :start_date => Date.today,
                                  :end_date => Date.tomorrow,
                                  :mentor => "A Craftsman",
                                  :skill => "student")
      api = double("warehouse_api").as_null_object
      allow_any_instance_of(ApplicantInteractor).to receive(:setup_warehouse_api) { api }
      interactor = ApplicantInteractor.new(applicant, {})
      interactor.update
      expect(api).to have_received(:add_student!)
    end
  end
end
