require 'spec_helper'
require "applicants/applicant_profile_presenter"
require "argon/applicant_offer_letter_generator"

describe ApplicantProfilePresenter do
  let(:applicant) do
    Footprints::Repository.applicant.create(
      :name => "Meagan",
      :applied_on => Date.parse("20140101"),
      :discipline => "developer",
      :skill => "resident",
      :location => "Chicago"
    )
  end
  let(:presenter) { ApplicantProfilePresenter.new(applicant) }
  let!(:craftsman) do
    Footprints::Repository.craftsman.create(
      :name => "A Craftsman",
      :email => "acraftsman@abcinc.com",
      :employment_id => "7"
    )
  end

  it "returns false if applicant has no background information" do
    presenter.has_background?.should be_false
  end

  it "returns true if applicant has background information" do
    app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.parse("20140101"), :codeschool => "Dev Bootcamp",
                                                   :discipline => "developer", :skill => "resident", :location => "Chicago"})
    app_presenter = ApplicantProfilePresenter.new(app)
    app_presenter.has_background?.should be_true
  end

  it "returns false if applicant has no application questions answered" do
    presenter.has_application_questions?.should be_false
  end

  it "returns true if applicant has application questions answered" do
    applicant.update(:about => "Some info")
    applicant.save!
    presenter.has_application_questions?.should be_true
  end

  it "displays the body of the messages correctly" do
    presenter.display_body("Hello\n").should == "Hello<br/>"
  end

  it "has the most recent interaction" do
    presenter.recent_interaction.should == "Jan 1, 2014"
  end

  it "has the interactions" do
    applicant.update(:initial_reply_on => Date.parse("20140105"))
    applicant.save!
    presenter.interactions.should == {"Initial Reply On"=>"Jan 5, 2014"}
  end

  context "#current_state" do
    it "waiting for initial reply when first applied and no action yet" do
      presenter.current_state.should == "Applied"
    end

    it "sent initial reply when steward has replied (initial_reply_on is set)" do
      app =  Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :initial_reply_on => Date.today,
                                                      :discipline => "developer", :skill => "resident", :location => "Chicago" })
      ApplicantProfilePresenter.new(app).current_state.should == "Contacted"
    end

    it "received challenge when steward has sent challenge (sent_challenge_on is set)" do
      app =  Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :initial_reply_on => Date.today, :sent_challenge_on => Date.today,
                                                      :discipline => "developer", :skill => "resident", :location => "Chicago" })
      ApplicantProfilePresenter.new(app).current_state.should == "Requested Submission"
    end

    it "needs to be reviewed when stewared has received challenge (completed_challenge_on is set)" do
      app =  Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :initial_reply_on => Date.today,
                                                      :sent_challenge_on => Date.today, :completed_challenge_on => Date.today, :discipline => "developer",
                                                      :skill => "resident", :location => "Chicago" })
      ApplicantProfilePresenter.new(app).current_state.should == "Submitted Code"
    end

    it "waiting for offer when steward has reviewed challenge (reviewed_on is set)" do
      app =  Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :initial_reply_on => Date.today,
                                                      :sent_challenge_on => Date.today, :completed_challenge_on => Date.today,
                                                      :reviewed_on => Date.today, :discipline => "developer", :skill => "resident", :location => "Chicago" })
      ApplicantProfilePresenter.new(app).current_state.should == "Received Feedback"
    end


    it "waiting on decision when steward has extended an offer letter (offered_on is set)" do
      app =  Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :initial_reply_on => Date.today,
                                                      :sent_challenge_on => Date.today, :completed_challenge_on => Date.today, :reviewed_on => Date.today, :offered_on => Date.today, :discipline => "developer",
                                                      :skill => "resident", :location => "Chicago" })
      ApplicantProfilePresenter.new(app).current_state.should == "Extended Offer"
    end

    it "completed application process when applicant has been hired (decision_made_on is set)" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today,  :initial_reply_on => Date.today,
                                                      :sent_challenge_on => Date.today, :completed_challenge_on => Date.today,
                                                      :reviewed_on => Date.today, :resubmitted_challenge_on => Date.today, :offered_on => Date.today,
                                                      :decision_made_on => Date.today, :hired => "no", :assigned_craftsman => "A Craftsman",
                                                      :discipline => "developer", :skill => "resident", :location => "Chicago" })
      ApplicantProfilePresenter.new(app).current_state.should == "Completed Application"
    end

    context "#url" do
      it "creates valid url syntax" do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "http://www.meaganwaller.com",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == ["http://www.meaganwaller.com"]
      end

      it "add http prefix if otherwise valid url " do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "www.meaganwaller.com",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == ["http://www.meaganwaller.com"]
      end

      it "doesn't add prefix if url has https prefix" do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "https://www.meaganwaller.com",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == ["https://www.meaganwaller.com"]

      end

      it "doesn't add http prefix if not otherwise valid" do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "No experience",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == []
      end

      it "deals with multiple urls" do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "http://meaganwaller.com http://github.com/meaganewaller",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == ["http://meaganwaller.com", "http://github.com/meaganewaller"]
      end

      it "deals with multiple unnecessary punctuation" do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "https://meaganwaller.com, http://github.com/meaganewaller;",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == ["https://meaganwaller.com", "http://github.com/meaganewaller"]
      end

     it "deals with multiple unnecessary punctuation" do
        app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.today, :url => "https://meaganwaller.com, github.com/meaganewaller;",
                                                       :discipline => "developer", :skill => "resident", :location => "Chicago"})
        ApplicantProfilePresenter.new(app).url.should == ["https://meaganwaller.com", "http://github.com/meaganewaller"]
      end

    end
  end

  context "#hire_action" do
    it "returns 'Hired' string if applicant has been hired" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.yesterday, :url => "https://meaganwaller.com, github.com/meaganewaller;", :hired => "yes", :start_date => Date.today, :end_date => Date.tomorrow, :mentor => "A Craftsman", :assigned_craftsman => "A Craftsman", :decision_made_on => DateTime.current, :discipline => "developer", :skill => "resident", :location => "Chicago" })
      expect(ApplicantProfilePresenter.new(app).hire_action).to eq("Hired")
    end

    it "returns a link to the hire action if applicant is ready for hire" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.yesterday, :start_date => Date.today, :end_date => Date.today + 6.months, :hired => "no_decision"})
      expect(ApplicantProfilePresenter.new(app).hire_action).to eq("<a href='#' class='decision_made_on button primary'>Hire</a>")
    end

    it "returns nothing if applicant is still going through the application process" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.yesterday, :start_date => nil, :end_date => nil, :hired => "no_decision"})
      expect(ApplicantProfilePresenter.new(app).hire_action).to be_nil
    end
  end

  context "#applicant_hired?" do
    it "returns false if no hiring decision has been made" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.yesterday, :url => "https://meaganwaller.com, github.com/meaganewaller;",
                                                     :hired => "no_decision", :discipline => "developer", :skill => "resident", :location => "Chicago" })
      expect(ApplicantProfilePresenter.new(app).applicant_hired?).to be_false
    end

    it "returns false if applicant was not hired" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.yesterday, :url => "https://meaganwaller.com, github.com/meaganewaller;",
                                                     :hired => "no", :assigned_craftsman => "A Craftsman", :decision_made_on => DateTime.current,
                                                     :discipline => "developer", :skill => "resident", :location => "Chicago"})
      expect(ApplicantProfilePresenter.new(app).applicant_hired?).to be_false
    end

    it "returns true if applicant was hired" do
      app = Footprints::Repository.applicant.create({:name => "Meagan", :applied_on => Date.yesterday, :url => "https://meaganwaller.com, github.com/meaganewaller;",
                                                     :hired => "yes", :start_date => Date.today, :end_date => Date.tomorrow, :mentor => "A Craftsman", :assigned_craftsman => "A Craftsman",
                                                     :decision_made_on => DateTime.current, :discipline => "developer", :skill => "resident", :location => "Chicago" })
      expect(ApplicantProfilePresenter.new(app).applicant_hired?).to be_true
    end
  end

  context "#can_be_unarchived?" do
    it "returns false for non-archived applicants" do
      applicant = Footprints::Repository.applicant.create({ :name => "Meagan",
                                                            :applied_on => Date.yesterday,
                                                            :discipline => "developer",
                                                            :archived => false,
                                                            :location => "Chicago" })

      expect(ApplicantProfilePresenter.new(applicant).can_be_unarchived?).to be_false
    end

    it "returns true for archived applicants that have not been hired" do
      applicant = Footprints::Repository.applicant.create({ :name => "Meagan",
                                                            :applied_on => Date.yesterday,
                                                            :discipline => "developer",
                                                            :archived => true,
                                                            :hired => "no",
                                                            :location => "Chicago" })

      expect(ApplicantProfilePresenter.new(applicant).can_be_unarchived?).to be_true
    end

    it "returns false for archived applicants that have been hired" do
      applicant = Footprints::Repository.applicant.create({ :name => "Meagan",
                                                            :applied_on => Date.yesterday,
                                                            :discipline => "developer",
                                                            :archived => true,
                                                            :hired => "yes",
                                                            :assigned_craftsman => craftsman.name,
                                                            :start_date => Date.today,
                                                            :end_date => Date.today,
                                                            :mentor => "A Craftsman",
                                                            :location => "Chicago" })

      expect(ApplicantProfilePresenter.new(applicant).can_be_unarchived?).to be_false
    end
  end

  context "#can_be_denied?" do
    it "returns true for applicants currently in process" do
      applicant = Footprints::Repository.applicant.create({:name => "Name",
                                                           :applied_on => Date.yesterday,
                                                           :assigned_craftsman => "A Craftsman",
                                                           :discipline => "developer",
                                                           :skill => "resident",
                                                           :location => "Chicago" })

      expect(ApplicantProfilePresenter.new(applicant).can_be_denied?).to be_true
    end

    it "returns false for applicants already denied" do
      applicant = Footprints::Repository.applicant.create({:name => "Name",
                                                           :applied_on => Date.yesterday,
                                                           :assigned_craftsman => "A Craftsman",
                                                           :discipline => "developer",
                                                           :skill => "resident",
                                                           :location => "Chicago",
                                                           :archived => true })

      expect(ApplicantProfilePresenter.new(applicant).can_be_denied?).to be_false
    end

    it "returns false for applicants already accepted/hired" do
      applicant = Footprints::Repository.applicant.create({:name => "Name",
                                                           :applied_on => Date.yesterday,
                                                           :assigned_craftsman => "A Craftsman",
                                                           :discipline => "developer",
                                                           :skill => "resident",
                                                           :location => "Chicago",
                                                           :archived => true,
                                                           :hired => "yes",
                                                           :start_date => Date.today,
                                                           :end_date => Date.today,
                                                           :mentor => "A Craftsman" })

      expect(ApplicantProfilePresenter.new(applicant).can_be_denied?).to be_false
    end
  end
end

