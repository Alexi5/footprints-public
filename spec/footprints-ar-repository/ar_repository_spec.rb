require "spec_helper"
require "ar_repository/ar_repository"

describe ArRepository do
  it "has an applicant repo" do
    ArRepository.applicant.should be_a ArRepository::ApplicantRepository
  end

  it "has a craftsman repo" do
    ArRepository.craftsman.should be_a ArRepository::CraftsmanRepository
  end

  it "has a message repo" do
    ArRepository.message.should be_a ArRepository::MessageRepository
  end

  it "has a user repo" do
    ArRepository.user.should be_a ArRepository::UserRepository
  end
end
