require 'repository'

class Note < ActiveRecord::Base

  belongs_to :applicant
  belongs_to :craftsman

  validates_presence_of :body

end
