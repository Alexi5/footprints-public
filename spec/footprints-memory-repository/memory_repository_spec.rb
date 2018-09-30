require 'spec_helper'
require 'memory_repository/applicant_repository'
require 'memory_repository/craftsman_repository'
require 'memory_repository/user_repository'
require 'memory_repository/message_repository'

describe MemoryRepository do
  it "has an applicant repo" do
    MemoryRepository.applicant.should be_a MemoryRepository::ApplicantRepository
  end

  it "has a craftsman repo" do
    MemoryRepository.craftsman.should be_a MemoryRepository::CraftsmanRepository
  end

  it "has a user repo" do
    MemoryRepository.user.should be_a MemoryRepository::UserRepository
  end

  it "has a message repo" do
    MemoryRepository.message.should be_a MemoryRepository::MessageRepository
  end
end
