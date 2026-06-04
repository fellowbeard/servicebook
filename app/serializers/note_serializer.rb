class NoteSerializer
  def initialize(note)
    @note = note
  end

  def as_json(*)
    {
      id: @note.id,
      body: @note.body,
      created_at: @note.created_at,
      updated_at: @note.updated_at
    }
  end
end