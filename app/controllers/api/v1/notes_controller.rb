class Api::V1::NotesController < Api::V1::BaseController
  before_action :require_write_access, only: [:create, :update, :destroy]
  before_action :set_note, only: [:show, :update, :destroy]

  def index
    notes = current_account.notes
    render json: notes.map { |note| NoteSerializer.new(note).as_json }
  end

  def show
    render json: NoteSerializer.new(@note).as_json
  end

  def create
    note = current_user.notes.new(note_params)
    if note.save
      render json: NoteSerializer.new(note).as_json, status: :created
    else
      render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      render json: NoteSerializer.new(@note).as_json
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    head :no_content
  end

  private

  def set_note
    @note = current_account.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:client_id, :body)
  end
end
