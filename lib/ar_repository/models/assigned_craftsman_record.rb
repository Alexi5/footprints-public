require 'repository'
class AssignedCraftsmanRecord < ActiveRecord::Base
  belongs_to :craftsman
  belongs_to :applicant
end
