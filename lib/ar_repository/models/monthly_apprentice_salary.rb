require 'repository'

class MonthlyApprenticeSalary < ActiveRecord::Base

  validates_presence_of   :duration
  validates_presence_of   :location
  validates_presence_of   :amount
  validates_uniqueness_of :duration, scope: :location

end
