require 'repository'
require 'applicants/applicant_index_presenter'
require 'applicants/applicant_presenter'
require 'applicants/applicant_profile_presenter'
require 'notes/notes_presenter'
require 'applicants/applicant_interactor'
require 'applicants/eighthlight_applicants_interactor'
require 'applicants/applicant_finder'
require 'applicant_dispatch/dispatcher'
require 'argon/applicant_offer_letter_generator'
require 'argon/offer_letter_post'
require 'applicants/generate_onboarding_letter'
require 'date'
require 'will_paginate/array'

class ApplicantsController < ApplicationController
  include ApplicantsHelper

  before_filter :authenticate, :employee?, :except => [:submit]
  before_filter :require_admin, :only => [:destroy, :new, :create, :hire, :make_decision, :unassigned, :assign_craftsman]

  def index
    @crafters      = Footprints::Repository.craftsman
    @applicants    = Footprints::ApplicantFinder.new.get_applicants(params).paginate(:page => params[:page], :per_page => 12)
    @presenter     = ApplicantIndexPresenter.new(@applicants)
  end

  # encrypt first & last name and email address
  def new
    @applicant = repo.applicant.new
  end

  def create
	#calls new from Applicant repo 
	# --> 'new' does not exist in applicant_repository, so it calls new from base_repository
    @applicant = repo.applicant.new(applicant_params)
    @applicant.save!
    redirect_to(applicant_path(@applicant), :notice => "Successfully created #{@applicant.name}")
  rescue StandardError => e
    flash.now[:error] = [e.message]
    render :new
  end

  def show
    @applicant = repo.applicant.find(params[:id])
    @presenter = ApplicantProfilePresenter.new(@applicant)
    @notes     = NotesPresenter.new(@applicant.notes)
    @note      = Note.new({:applicant_id => @applicant.id})
  end

  def edit
    @applicant = repo.applicant.find(params[:id])
  end

  def update
    @applicant = repo.applicant.find(params[:id])
    interactor = ApplicantInteractor.new(@applicant, applicant_params_for_update, session[:id_token])
    interactor.update
    redirect_to applicant_path(@applicant), :notice => interactor.get_notice
  rescue StandardError => e
    if @applicant.errors.full_messages.empty?
      flash.now[:error] = [e.message]
    else
      flash.now[:error] = @applicant.errors.full_messages
    end
    render :edit
  end

  def unarchive
    applicant = repo.applicant.find(params[:id])
    applicant.update_attributes!(archived: false)
    redirect_to applicants_path
  end

  def update_state
    @applicant = repo.applicant.find(params[:id])
    ApplicantInteractor.new(@applicant, applicant_params).update_state
    render :json => { :success => "true" }
  rescue StandardError => e
    render :json => { :success => "false", :message => e.message }
  end

  def deny_application
    @applicant = repo.applicant.find(params[:id])
    @applicant.update_attributes({:hired => "no", :archived => true})
    path_for_redirect = determine_redirect_path_for_denial(@applicant)
    redirect_to path_for_redirect, :notice => "Successfully denied and archived applicant"
  end

  def update_end_date
    @applicant = repo.applicant.find(params[:id])
    params[:applicant][:end_date] = params[:end_date]
  end

  def update_employment_dates
    @applicant = repo.applicant.find(params[:id])
    end_date = calculate_end_date(params[:applicant][:start_date], params[:applicant][:duration])
    params[:applicant][:end_date] = end_date
    ApplicantInteractor.new(@applicant, employment_date_params).update
    render :json => { :success => "true",
                      :applicantId => @applicant.id,
                      :duration => params[:applicant][:duration],
                      :pt_ft => params[:applicant][:pt_ft],
                      :hours_per_week => params[:applicant][:hours_per_week],
                      :withdraw_offer_date => params[:applicant][:withdraw_offer_date] }
  rescue StandardError => e
    render :json => { :sucesss => "false", :message => e.message }
  end

  def hire
    @applicant = repo.applicant.find(params[:id])
    @presenter = ApplicantProfilePresenter.new(@applicant)
    render :layout => false
  end

  def make_decision
    applicant = repo.applicant.find(params[:id])
    apprentice = repo.apprentice.new
    ApplicantInteractor.new(applicant, hiring_decision_params, session[:id_token]).update_applicant_for_hiring

    apprentice.name = applicant.name
    apprentice.email = applicant.email
    apprentice.location = applicant.location
    apprentice.position = applicant.discipline
    apprentice.mentor = applicant.mentor
    apprentice.start_date = applicant.start_date
    apprentice.end_date = applicant.end_date
    apprentice.save!

    applicant.destroy

    redirect_to apprentices_path, :flash => { :notice => "Applicant hired" }
  rescue StandardError => e
    flash[:error] = [e.message]
    redirect_to applicant_path(applicant)
  end

  def destroy
    repo.applicant.destroy(params[:id])
    redirect_to(applicants_path, notice: "Successfully deleted applicant")
  end

  def submit
    status, body = EighthlightApplicantsInteractor.apply(eighthlight_applicant_params)
    render :status => status, :text => body, :layout => false
  end

  def unassigned
    @applicant_presenter = ApplicantPresenter.new
    applicants = repo.applicant.get_unassigned_unarchived_applicants
    @applicants = @applicant_presenter.sort_by_date(applicants)
    @craftsmen = Footprints::Repository.craftsman.all
  end

  def assign_craftsman
    applicant_id = params[:applicant_to_assign]["id"]
    chosen_crafter = params[:applicant_to_assign]["chosen_crafter"]
    applicant = repo.applicant.find_by_id(applicant_id)
    steward = repo.craftsman.find_by_email(ENV['STEWARD'])

    if automatically_assigned?
      ApplicantDispatch::Dispatcher.new(applicant, steward).assign_applicant
    else
      ApplicantDispatch::Dispatcher.new(applicant, steward).assign_applicant_specific(chosen_crafter)
    end
    redirect_to(unassigned_applicants_path, notice: "Assigned #{applicant.name} to #{applicant.assigned_craftsman}")
  end

  def assign_craftsman_from_applicant
    applicant_id = params[:applicant_to_assign]["id"]
    chosen_crafter = params[:applicant_to_assign]["chosen_crafter"]
    applicant = repo.applicant.find_by_id(applicant_id)
    steward = repo.craftsman.find_by_email(ENV['STEWARD'])

    if automatically_assigned?
      ApplicantDispatch::Dispatcher.new(applicant, steward).assign_applicant
    else
      ApplicantDispatch::Dispatcher.new(applicant, steward).assign_applicant_specific(chosen_crafter)
    end
    redirect_to applicant_path(applicant), notice: "Assigned #{applicant.name} to #{applicant.assigned_craftsman}"
  end

  def offer_letter_form
    applicant = repo.applicant.find(params[:id])
    @duration_options = repo.monthly_apprentice_salary.find_all_durations_by_location(applicant.location)
    render_offer_letter_form(applicant.location)
  end

  def offer_letter
    applicant = repo.applicant.find(params[:id])
    generator = ApplicantOfferLetterGenerator.new(applicant, params)
    json_data = generator.build_offer_letter_as_json
    NotificationMailer.offer_letter_generated(applicant).deliver
    respond_to do |format|
      format.pdf { send_data OfferLetterPost.get_pdf(json_data), :type => "application/pdf" }
    end
  end

  def onboarding_letters
    applicant = repo.applicant.find(params[:id])
    template_root = "#{Rails.root}/lib/argon"
    onboarding_letter = GenerateOnboardingLetter.new(applicant, template_root).call
    respond_to do |format|
      format.pdf { send_data(onboarding_letter, :type => "application/pdf") }
    end
  end

  private

  def automatically_assigned?
    params[:applicant_to_assign]["chosen_crafter"] == "auto"
  end

  def render_offer_letter_form(location)
    if location_is_unknown(location)
      render "unknown_location_offer_letter_form", layout: false
    elsif same_location?(location, "london")
      render "london_offer_letter_form", layout: false
    elsif same_location?(location, "chicago")
      render "chicago_offer_letter_form", layout: false
    elsif same_location?(location, "los angeles")
      render "los_angeles_offer_letter_form", layout: false
    end
  end

  def location_is_unknown(location)
    location.to_s == ''
  end

  def same_location?(location_one, location_two)
    location_one.downcase == location_two.downcase
  end

  def eighthlight_applicant_params
    {
      :name              => params[:name],
      :applied_on        => Time.zone.now.to_date,
      :email             => params[:email],
      :url               => params[:publication],
      :about             => params[:story],
      :software_interest => params[:passion],
      :reason            => params[:desire],
      :discipline        => params[:type],
      :location          => params[:location],
      :skill             => params[:position]
    }
  end

  def calculate_end_date(start_date, duration)
    target_day_of_week = 7
    start = Date.parse(start_date)
    end_date = start >> duration.to_i
    distance = target_day_of_week - end_date.cwday
    end_date + (distance.abs < 4 ? distance : distance.abs - 7).days
  end

  def employment_date_params
    params.require(:applicant).permit(:start_date, :end_date, :offered_on)
  end

  def hiring_decision_params
    params.require(:applicant).permit(:decision_made_on, :hired, :mentor)
  end

  def applicant_params
    params.require(:applicant).permit(:name, :email, :applied_on, :initial_reply_on, :sent_challenge_on, :completed_challenge_on, :reviewed_on, :resubmitted_challenge_on, :decision_made_on, :assigned_craftsman, :code_submission, :codeschool, :college_degree, :cs_degree, :worked_as_dev, :additional_notes, :url, :craftsman_id, :has_steward, :skill, :discipline, :archived, :hired, :about, :software_interest, :reason, :start_date, :end_date, :location, :offered_on)
  end

  def applicant_params_for_update
    params.require(:applicant).permit(:name, :email, :initial_reply_on, :sent_challenge_on, :completed_challenge_on, :reviewed_on, :resubmitted_challenge_on, :decision_made_on, :assigned_craftsman, :code_submission, :codeschool, :college_degree, :cs_degree, :worked_as_dev, :additional_notes, :url, :craftsman_id, :has_steward, :skill, :discipline, :archived, :hired, :about, :software_interest, :reason, :start_date, :end_date, :location, :offered_on)
  end

  def apprentice_params
    params.require(:apprentice).permit(:name, :email, :applied_on, :position, :location, :start_date, :end_date, :mentor)
  end

  def determine_redirect_path_for_denial(applicant)
    if applicant.assigned_craftsman
      root_path
    else
      unassigned_applicants_path
    end
  end
end
