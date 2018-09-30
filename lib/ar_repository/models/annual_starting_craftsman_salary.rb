require 'repository'

class AnnualStartingCraftsmanSalary < ActiveRecord::Base

  validates_presence_of   :location
  validates_presence_of   :amount
  validates_uniqueness_of :location

end
