require 'memory_repository/models/applicant'
require 'memory_repository/base_repository'
require 'repository'

module MemoryRepository
  class ApplicantRepository
    include BaseRepository

    def new(attrs = {})
      MemoryRepository::Applicant.new(attrs)
    end

    def create(attrs = {})
      applicant = new(attrs)
      if !exisiting_email?(applicant.email) && applicant.valid?
        save(applicant)
      else
        applicant.add_error(:email, 'has already been taken')
        raise Footprints::RecordNotValid.new(applicant)
      end
      applicant
    end

    def find_by_email(email)
      return nil if email.nil?
      records.values.find { |r| r.email == email }
    end

    def find_by_id(id)
      records[id]
    end

    def find_by_name(name)
      records.values.find { |r| r.name == name }
    end

    def find_like(term)
      records.values.select { |r| r.name.include?(term) }
    end

    def get_all_archived_applicants
      records.values.select {|r| r.archived }
    end

    def get_all_unarchived_applicants
      records.values.select {|r| !r.archived }
    end

    def where(string_query, term)
      matches = records.values.select { |r| r.name.start_with?(term) }
      matches
    end

    def get_unassigned_unarchived_applicants
      records.values.select{|r| r.assigned_craftsman == nil && !r.archived}
    end

    def get_applicants_by_state(state)
      records.values.select do |applicant| 
        ApplicantStateMachine.determine_state(applicant) == state
      end
    end


    private
    def exisiting_email?(email)
      !find_by_email(email).nil?
    end

  end
end
