require 'rails_helper'

RSpec.describe 'Api::V1::NotesController', type: :request do
  let!(:account) { create(:account) }
  let!(:owner) { create(:user, account: account) }
  let!(:staff) { create(:user, :staff, account: account) }
  let!(:read_only_user) { create(:user, :read_only, account: account) }
  let!(:client) { create(:client, account: account, user: owner) }
  let!(:note) { create(:note, client: client, user: owner, body: 'Initial note') }

  describe 'GET /api/v1/notes' do
    it 'returns all notes for the current account' do
      create(:note, client: client, user: owner, body: 'Another note')

      get '/api/v1/notes', headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json).to be_an(Array)
      expect(json.length).to eq(2)
      expect(json.map { |n| n['body'] }).to include('Initial note', 'Another note')
    end

    it 'requires authentication' do
      get '/api/v1/notes'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns notes only for the authenticated user\'s account' do
      other_account = create(:account)
      other_user = create(:user, account: other_account)
      other_client = create(:client, account: other_account, user: other_user)
      create(:note, client: other_client, user: other_user, body: 'Other account note')

      get '/api/v1/notes', headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(1)
      expect(json.first['body']).to eq('Initial note')
    end

    it 'is accessible to read-only users' do
      get '/api/v1/notes', headers: auth_headers(read_only_user)

      expect(response).to have_http_status(:ok)
      expect(json).to be_an(Array)
    end
  end

  describe 'GET /api/v1/notes/:id' do
    it 'returns a specific note' do
      get "/api/v1/notes/#{note.id}", headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(note.id)
      expect(json['body']).to eq('Initial note')
      expect(json['user_id']).to eq(owner.id)
      expect(json['client_id']).to eq(client.id)
    end

    it 'returns not found for a non-existent note' do
      get '/api/v1/notes/99999', headers: auth_headers(owner)

      expect(response).to have_http_status(:not_found)
    end

    it 'prevents access to notes from other accounts' do
      other_account = create(:account)
      other_user = create(:user, account: other_account)
      other_client = create(:client, account: other_account, user: other_user)
      other_note = create(:note, client: other_client, user: other_user)

      get "/api/v1/notes/#{other_note.id}", headers: auth_headers(owner)

      expect(response).to have_http_status(:not_found)
    end

    it 'is accessible to read-only users' do
      get "/api/v1/notes/#{note.id}", headers: auth_headers(read_only_user)

      expect(response).to have_http_status(:ok)
      expect(json['body']).to eq('Initial note')
    end
  end

  describe 'POST /api/v1/notes' do
    it 'creates a note for a valid client in the account' do
      post '/api/v1/notes', headers: auth_headers(owner), params: {
        note: { client_id: client.id, body: 'New note about the client' },
      }

      expect(response).to have_http_status(:created)
      expect(json['body']).to eq('New note about the client')
      expect(json['client_id']).to eq(client.id)
      expect(json['user_id']).to eq(owner.id)

      expect(Note.last.body).to eq('New note about the client')
      expect(Note.last.user_id).to eq(owner.id)
    end

    it 'assigns the current user to the note' do
      post '/api/v1/notes', headers: auth_headers(staff), params: {
        note: { client_id: client.id, body: 'Staff note' },
      }

      expect(response).to have_http_status(:created)
      expect(json['user_id']).to eq(staff.id)
    end

    it 'prevents read-only users from creating notes' do
      post '/api/v1/notes', headers: auth_headers(read_only_user), params: {
        note: { client_id: client.id, body: 'Blocked note' },
      }

      expect(response).to have_http_status(:forbidden)
      expect(json['error']).to eq('Read-only users cannot make changes.')
    end

    it 'returns unprocessable entity for missing body' do
      post '/api/v1/notes', headers: auth_headers(owner), params: {
        note: { client_id: client.id, body: '' },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors']).to include("Body can't be blank")
    end

    it 'returns unprocessable entity for missing client_id' do
      post '/api/v1/notes', headers: auth_headers(owner), params: {
        note: { body: 'Note without client' },
      }

      expect(response).to have_http_status(:not_found)
    end

    it 'prevents creating a note for a client in another account' do
      other_account = create(:account)
      other_user = create(:user, account: other_account)
      other_client = create(:client, account: other_account, user: other_user)

      post '/api/v1/notes', headers: auth_headers(owner), params: {
        note: { client_id: other_client.id, body: 'Unauthorized note' },
      }

      expect(response).to have_http_status(:not_found)
    end

    it 'supports multiline notes with special characters' do
      multiline_body = "Line 1\nLine 2\nSpecial: !@#$%^&*()"
      post '/api/v1/notes', headers: auth_headers(owner), params: {
        note: { client_id: client.id, body: multiline_body },
      }

      expect(response).to have_http_status(:created)
      expect(json['body']).to eq(multiline_body)
    end

    it 'requires authentication' do
      post '/api/v1/notes', params: {
        note: { client_id: client.id, body: 'Unauthenticated note' },
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/notes/:id' do
    it 'updates a note body for write users' do
      patch "/api/v1/notes/#{note.id}", headers: auth_headers(owner), params: {
        note: { body: 'Updated note' },
      }

      expect(response).to have_http_status(:ok)
      expect(json['body']).to eq('Updated note')
      expect(note.reload.body).to eq('Updated note')
    end

    it 'allows staff to update notes' do
      patch "/api/v1/notes/#{note.id}", headers: auth_headers(staff), params: {
        note: { body: 'Staff update' },
      }

      expect(response).to have_http_status(:ok)
      expect(json['body']).to eq('Staff update')
    end

    it 'prevents read-only users from updating notes' do
      patch "/api/v1/notes/#{note.id}", headers: auth_headers(read_only_user), params: {
        note: { body: 'Blocked update' },
      }

      expect(response).to have_http_status(:forbidden)
      expect(json['error']).to eq('Read-only users cannot make changes.')
      expect(note.reload.body).to eq('Initial note')
    end

    it 'returns not found for non-existent note' do
      patch '/api/v1/notes/99999', headers: auth_headers(owner), params: {
        note: { body: 'Updated' },
      }

      expect(response).to have_http_status(:not_found)
    end

    it 'prevents updating notes from another account' do
      other_account = create(:account)
      other_user = create(:user, account: other_account)
      other_client = create(:client, account: other_account, user: other_user)
      other_note = create(:note, client: other_client, user: other_user)

      patch "/api/v1/notes/#{other_note.id}", headers: auth_headers(owner), params: {
        note: { body: 'Unauthorized update' },
      }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns unprocessable entity when body is emptied' do
      patch "/api/v1/notes/#{note.id}", headers: auth_headers(owner), params: {
        note: { body: '' },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors']).to include("Body can't be blank")
      expect(note.reload.body).to eq('Initial note')
    end

    it 'requires authentication' do
      patch "/api/v1/notes/#{note.id}", params: {
        note: { body: 'Unauthenticated update' },
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/notes/:id' do
    it 'destroys a note for write users' do
      delete "/api/v1/notes/#{note.id}", headers: auth_headers(owner)

      expect(response).to have_http_status(:no_content)
      expect(Note.find_by(id: note.id)).to be_nil
    end

    it 'allows staff to delete notes' do
      note_to_delete = create(:note, client: client, user: owner)
      delete "/api/v1/notes/#{note_to_delete.id}", headers: auth_headers(staff)

      expect(response).to have_http_status(:no_content)
      expect(Note.find_by(id: note_to_delete.id)).to be_nil
    end

    it 'prevents read-only users from deleting notes' do
      delete "/api/v1/notes/#{note.id}", headers: auth_headers(read_only_user)

      expect(response).to have_http_status(:forbidden)
      expect(json['error']).to eq('Read-only users cannot make changes.')
      expect(Note.find_by(id: note.id)).to eq(note)
    end

    it 'returns not found for non-existent note' do
      delete '/api/v1/notes/99999', headers: auth_headers(owner)

      expect(response).to have_http_status(:not_found)
    end

    it 'prevents deleting notes from another account' do
      other_account = create(:account)
      other_user = create(:user, account: other_account)
      other_client = create(:client, account: other_account, user: other_user)
      other_note = create(:note, client: other_client, user: other_user)

      delete "/api/v1/notes/#{other_note.id}", headers: auth_headers(owner)

      expect(response).to have_http_status(:not_found)
      expect(Note.find_by(id: other_note.id)).to eq(other_note)
    end

    it 'requires authentication' do
      delete "/api/v1/notes/#{note.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(Note.find_by(id: note.id)).to eq(note)
    end
  end
end
