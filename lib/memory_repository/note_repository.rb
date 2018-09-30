require 'memory_repository/models/note'
require 'memory_repository/base_repository'
require 'repository'

module MemoryRepository
  class NoteRepository
    include BaseRepository

    def model_class
      ::Note
    end

    def new(attrs = {})
      model_class.new(attrs)
    end

    def create(attrs = {})
      save(new(attrs))
    end

    def find_by_applicant_id(applicant_id)
      records.values.find { |r| r.applicant_id == applicant_id }
    end

  end
end
