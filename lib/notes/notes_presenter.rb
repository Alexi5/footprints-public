require 'notes/note_presenter'

class NotesPresenter
  def initialize(notes)
    @collection = notes
    @notes = notes.map { |note| NotePresenter.new(note) }
  end

  def each(&block)
    @notes.each(&block)
  end
end
