require 'memory_repository/applicant_repository'
require 'memory_repository/craftsman_repository'
require 'memory_repository/user_repository'
require 'memory_repository/assigned_craftsman_record_repository'
require 'memory_repository/message_repository'

module MemoryRepository
  def self.applicant
    @applicant_repo ||= ApplicantRepository.new
  end

  def self.craftsman
    @craftsman_repo ||= CraftsmanRepository.new
  end

  def self.user
    @user_repo ||= UserRepository.new
  end

  def self.message
    @message_repo ||= MessageRepository.new
  end

  def self.assigned_craftsman_record
    @assigned_craftsman_record ||= AssignedCraftsmanRecordRepository.new
  end
end
