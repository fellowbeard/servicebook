class NoteSerializer
  def initialize(note)
    @note = note
  end

  def as_json(*)
    {
      id: @note.id,
      account_id: @note.account_id,
      client_id: @note.client_id,
      user_id: @note.user_id,
      body: @note.body,
      created_at: @note.created_at,
      updated_at: @note.updated_at
    }
  end
end