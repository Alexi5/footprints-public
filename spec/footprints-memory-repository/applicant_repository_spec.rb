require 'spec_helper'
require 'memory_repository/applicant_repository'
require './spec/footprints/shared_examples/applicant_examples'

describe MemoryRepository::ApplicantRepository do
  it_behaves_like "applicant repository"
end
