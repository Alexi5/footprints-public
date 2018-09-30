require 'spec_helper'
require 'ar_repository/user_repository'
require './spec/footprints/shared_examples/user_examples'

describe ArRepository::UserRepository do
  it_behaves_like "user repository"
end
