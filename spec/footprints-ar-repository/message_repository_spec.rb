require 'spec_helper'
require 'ar_repository/message_repository'
require './spec/footprints/shared_examples/message_examples'

describe ArRepository::MessageRepository do
  it_behaves_like "message repository"
end
