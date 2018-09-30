require 'spec_helper'
require 'ar_repository/note_repository'
require './spec/footprints/shared_examples/note_examples'

describe ArRepository::NoteRepository do
  it_behaves_like "note repository"
end
