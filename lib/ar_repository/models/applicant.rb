require 'repository'
require './app/helpers/applicants_helper'
require './app/validators/date_validator'
require './app/validators/url_validator'
require './app/validators/craftsman_validator'

class Applicant < ActiveRecord::Base
  include ActiveModel::Validations
  include ApplicantsHelper

  scope :not_archived, -> { where(:archived => false) }

  has_many :messages
  has_many :notes
  has_many :assigned_craftsman_records, autosave: true
  has_many :notifications
  belongs_to :craftsman

  validates_with DateValidator
  validates_with UrlValidator
  validates_with ApplicantValidator
  validates :code_submission, uniqueness: true, allow_nil: true
  validates :name, presence: true
  validates :applied_on, presence: true
  validates :email, uniqueness: true, allow_nil: true
  validate :valid_hiring_decision
  validate :end_date_after_start_date
  validate :must_have_start_date_when_hired
  validate :must_have_end_date_when_hired
  validate :must_have_mentor_when_hired
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => true

  before_save :nilify_blanks
  before_save :set_craftsman_data
  before_save :archive_if_decision_made

  def self.code_schools
    [
      'None',
      'App Academy',
      'Bitmaker Labs',
      'Dev Bootcamp',
      'General Assembly',
      'Google SOC',
      'HackBright',
      'Hacker School',
      'Launch Academy',
      'Makers Academy',
      'Mobile Makers',
      'Start Up Institute',
      'Starter League',
    ]
  end

  def self.hiring_decisions
    ["no_decision", "no", "yes"]
  end

  def valid_hiring_decision
    unless self.class.hiring_decisions.include?(hired)
      errors.add(:hired, "must be set to no_decision, yes, or no")
    end
  end

  def set_craftsman_data
    craftsman_name = self.assigned_craftsman
    if craftsman_name.blank?
      set_no_craftsman
    else
      set_craftsman_by_name(craftsman_name)
    end
    self
  end

  def set_no_craftsman
    self.assigned_craftsman = nil
    self.craftsman_id = nil
    self.has_steward = false
  end

  def set_craftsman_by_name(craftsman_name)
    craftsman = Footprints::Repository.craftsman.find_by_name(craftsman_name)
    if craftsman
      self.craftsman_id = craftsman.id
    else
      self.craftsman_id = nil
    end
  end

  def outstanding?(how_many)
    first_notification = Notification.where(:applicant_id => self.id,
                                            :craftsman_id => self.craftsman_id).first
    date = first_notification.try(:created_at) || self.created_at
    !has_steward && (date < how_many.days.ago if date)
  end

  def student?
    self.skill == "student"
  end

  def resident?
    self.skill == "resident"
  end

  def hired?
    hired == "yes"
  end

  def first_name
    name.split(" ")[0]
  end

  def last_name
    name.split(" ")[1]
  end

  def nilify_blanks
    self.attributes.each do |attr, value|
      if value.blank? && value != false
        self.send("#{attr}=", nil)
      end
    end
  end

  private

  def archive_if_decision_made
    self.archived = true if decision_made_on
  end

  def end_date_after_start_date
    if start_date && end_date && start_date > end_date
      errors.add(:end_date, "must come after the start date")
    end
  end

  def must_have_start_date_when_hired
    if hired == "yes" && start_date.nil?
      errors.add(:start_date, "must be selected when hiring applicant")
    end
  end

  def must_have_end_date_when_hired
    if hired == "yes" && end_date.nil?
      errors.add(:end_date, "must be selected when hiring applicant")
    end
  end

  def must_have_mentor_when_hired
    if hired == "yes" && mentor.nil?
      errors.add(:mentor, "must be selected when hiring an applicant")
    end
  end
end
