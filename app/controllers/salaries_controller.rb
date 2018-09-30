require 'salaries/salary_presenter'
require 'salaries/salary_updater'
require 'repository'

class SalariesController < ApplicationController
  before_filter :authenticate, :employee?
  before_filter :require_admin

  def edit
    monthly_salaries = Footprints::Repository.monthly_apprentice_salary.all
    annual_salaries = Footprints::Repository.annual_starting_craftsman_salary.all
    @salary_presenter = SalaryPresenter.new(monthly_salaries, annual_salaries, params)
    render "salary_update_form"
  end

  def update
    SalaryUpdater.new(params).update
    redirect_to "/salaries/edit", :notice => "Successfully updated salaries."
  rescue Exception => e
    flash[:error] = [e.message]
    redirect_to "/salaries/edit"
  end

  def create_monthly
    SalaryUpdater.new(monthly_salary_params).create_monthly
    redirect_to("/salaries/edit", :notice => "Successfully created salary.")
  rescue StandardError => e
    flash[:error] = [e.message]
    redirect_to "/salaries/edit"
  end

  def destroy
    SalaryUpdater.new(params).destroy
    redirect_to salaries_path, :notice => "Successfully deleted salary."
  end

  private

  def monthly_salary_params
    params.require(:salary).permit(:duration, :location, :amount)
  end

  def annual_salary_params
    params.require(:salary).permit(:location, :amount)
  end
end
