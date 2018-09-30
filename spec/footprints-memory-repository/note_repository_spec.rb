require 'spec_helper'
require 'memory_repository/note_repository'
require './spec/footprints/shared_examples/note_examples'

describe MemoryRepository::NoteRepository do
  it_behaves_like "note repository"
end
