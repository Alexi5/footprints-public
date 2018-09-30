require 'repository'

module Footprints
  class ApplicantFinder
    def repo
      Footprints::Repository.applicant
    end

    def get_applicants(params)
      if params['status'] == 'archived'
        repo.get_all_archived_applicants
      elsif ApplicantStateMachine::STATES.include?(params['status']) 
        repo.get_applicants_by_state(params['status'])
      elsif params['term'].present?
        repo.find_like(params['term'])
      else
        repo.get_all_unarchived_applicants
      end
    end
  end
end
