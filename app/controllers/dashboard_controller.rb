require 'applicants/applicant_index_presenter'
require 'dashboard/dashboard_interactor'

class DashboardController < ApplicationController
  before_filter :authenticate, :employee?

  def index
    @craftsman = current_user.craftsman
    @confirmed_applicants = interactor.confirmed_applicants(@craftsman)
    @not_yet_responded_applicants = interactor.not_yet_responded_applicants(@craftsman)
    @presenter = ApplicantIndexPresenter.new(@confirmed_applicants)
  end

  def confirm_applicant_assignment
    @applicant = repo.applicant.find_by_id(params[:id])
    interactor.assign_steward_for_applicant(@applicant)
    redirect_to root_path, :notice => "Confirmed"
  end

  def decline_applicant_assignment
    @applicant = repo.applicant.find_by_id(params[:id])
    interactor.decline_applicant(@applicant)
    interactor.assign_new_craftsman(@applicant)
    redirect_to root_path, :notice => "Declined"
  end

  def decline_all_applicants
    craftsman = current_user.craftsman
    interactor.decline_all_applicants_and_set_availability_date(craftsman, params[:unavailable_until])
    redirect_to root_path, :notice => "Declined All Applicants"
  rescue DashboardInteractor::InvalidAvailabilityDate => e
    redirect_to root_path, flash: { error: [e.message] }
  end

  private

  def interactor
    DashboardInteractor.new(repo.craftsman)
  end
end
