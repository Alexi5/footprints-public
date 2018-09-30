require "active_record"
require "safe_yaml"

db_yaml = File.join(Rails.root, './config/database.yml')
dbconfig = YAML.safe_load(File.open(db_yaml))

ActiveRecord::Base.establish_connection(dbconfig[Rails.env])

require 'repository'
require 'ar_repository/applicant_repository'
require 'ar_repository/craftsman_repository'
require 'ar_repository/apprentice_repository'
require 'ar_repository/message_repository'
require 'ar_repository/user_repository'
require 'ar_repository/note_repository'
require 'ar_repository/assigned_craftsman_record_repository'
require 'ar_repository/notification_repository'
require 'ar_repository/monthly_apprentice_salary_repository'
require 'ar_repository/annual_starting_craftsman_salary_repository'

module ArRepository
  def self.applicant
    @applicant_repo ||= ApplicantRepository.new
  end

  def self.apprentice
    @apprentice_repo ||= ApprenticeRepository.new
  end

  def self.craftsman
    @craftsman_repo ||= CraftsmanRepository.new
  end

  def self.message
    @message_repo ||= MessageRepository.new
  end

  def self.user
    @user_repo ||= UserRepository.new
  end

  def self.notes
    @note_repo ||= NoteRepository.new
  end

  def self.assigned_craftsman_record
    @assigned_craftsman_record_repo ||= AssignedCraftsmanRecordRepository.new
  end

  def self.notification
    @notification ||= NotificationRepository.new
  end

  def self.monthly_apprentice_salary
    @monthly_apprentice_salary ||= MonthlyApprenticeSalaryRepository.new
  end

  def self.annual_starting_craftsman_salary
    @annual_starting_craftsman_salary ||= AnnualStartingCraftsmanSalaryRepository.new
  end

end

Footprints::Repository.register_repo(ArRepository)
