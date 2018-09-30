require 'spec_helper'
require 'memory_repository/assigned_craftsman_record_repository'
require './spec/footprints/shared_examples/assigned_craftsman_record_examples'

describe MemoryRepository::AssignedCraftsmanRecordRepository do
  it_behaves_like "assigned craftsman record repository"
end
