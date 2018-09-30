require 'repository'
require 'craftsmen/skills'

class Craftsman < ActiveRecord::Base
  include ActiveModel::Validations
  default_scope { where(archived: false) }

  self.primary_key = 'employment_id'

  has_one :user, :dependent => :nullify
  has_many :applicants, -> { not_archived }
  has_many :assigned_craftsman_records, autosave: true
  has_many :notes
  has_many :notifications

  validates_with CraftsmanValidator
  validates :employment_id, presence: true, uniqueness: true

  def first_name
    name.split(" ")[0]
  end

  def flag_archived!
    update_attribute(:archived, true)
  end

  def self.create_footprints_steward(id)
    Craftsman.create!(:name => "Footprints Steward",
                      :email => ENV["STEWARD"],
                      :employment_id => id)
  rescue StandardError => e
    Rails.logger.error("Couldn't create steward with that employment_id. Retrying.")
    self.create_footprints_steward(id + 1) unless id > 1010
    Rails.logger.error("Couldn't create steward: #{e}")
  end

  def is_seeking_for?(desired_skill)
    skill == desired_skill
  end

  def previously_denied_applicant?(applicant)
    assigned_craftsman_records.where(:applicant_id => applicant.id).any?
  end

  def number_of_current_assigned_applicants
    assigned_craftsman_records.where(:current => true).count
  end
end
