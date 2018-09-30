require 'repository'
require 'craftsmen/craftsmen_interactor'
require 'craftsmen/craftsmen_presenter'
require 'craftsmen/skills'

class CraftsmenController < ApplicationController
  before_filter :authenticate, :employee?
  before_filter :normalize_status, :only => [:index]

  def profile
    @craftsman = current_user.craftsman
  end

  def seeking
    craftsmen_presenter = CraftsmenPresenter.new(Footprints::Repository.craftsman)
    @craftsmen_seeking_residents = craftsmen_presenter.seeking_resident_apprentice
    @craftsmen_seeking_students  = craftsmen_presenter.seeking_student_apprentice
  end

  def update
    @craftsman = current_user.craftsman
    interactor = CraftsmenInteractor.new(@craftsman)
    interactor.update(craftsman_params)

    redirect_to profile_path, :notice => "Successfully saved profile"
  rescue CraftsmenInteractor::InvalidData => e
    @craftsman.attributes = craftsman_params

    flash.now[:error] = [e.message]
    render :profile
  end

  private

  def normalize_status
    if params["craftsman"]
      params["craftsman"]["status"] = params["craftsman"]["status"].titleize
    end
  end

  def craftsman_params
    params.require(:craftsman).permit(:status, :has_apprentice, :seeking, :skill, :location, :unavailable_until)
  end
end
