require "rails_helper"

RSpec.describe "Api::V1 CRUD and authorization", type: :request do
  let!(:account) { Account.create!(business_name: "Acme Corp") }
  let!(:owner) do
    account.users.create!(
      first_name: "Owner",
      last_name: "One",
      email: "owner@example.com",
      role: "owner",
      password: "password",
      password_confirmation: "password"
    )
  end
  let!(:staff) do
    account.users.create!(
      first_name: "Staff",
      last_name: "Member",
      email: "staff@example.com",
      role: "staff",
      password: "password",
      password_confirmation: "password"
    )
  end
  let!(:read_only_user) do
    account.users.create!(
      first_name: "Read",
      last_name: "Only",
      email: "read_only@example.com",
      role: "read_only",
      password: "password",
      password_confirmation: "password"
    )
  end
  let!(:client) { account.clients.create!(first_name: "Jane", last_name: "Doe", email: "jane@example.com", phone: "555-1212", user: owner) }
  let!(:resource) { account.resources.create!(name: "Conference Room") }
  let!(:service) { account.services.create!(title: "Consultation", price: 140.0, duration_minutes: 45, user: owner) }
  let!(:appointment) do
    appointment = account.appointments.create!(scheduled_at: 3.days.from_now, status: "scheduled", user: owner, client: client, resource: resource)
    appointment.services << service
    appointment
  end

  describe "clients" do
    it "creates and updates a client for write users" do
      post "/api/v1/clients", headers: auth_headers(owner), params: {
        client: { first_name: "New", last_name: "Client", email: "new@example.com", phone: "555-9876" }
      }

      expect(response).to have_http_status(:created)
      expect(json["first_name"]).to eq("New")

      patch "/api/v1/clients/#{client.id}", headers: auth_headers(owner), params: { client: { phone: "555-0000" } }
      expect(response).to have_http_status(:ok)
      expect(json["phone"]).to eq("555-0000")
    end

    it "prevents read-only users from creating clients" do
      post "/api/v1/clients", headers: auth_headers(read_only_user), params: {
        client: { first_name: "Block", last_name: "User", email: "blocked@example.com" }
      }

      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Read-only users cannot make changes.")
    end

    it "returns client details and allows deletion" do
      get "/api/v1/clients/#{client.id}", headers: auth_headers(owner)
      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq(client.email)

      delete "/api/v1/clients/#{client.id}", headers: auth_headers(owner)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "resources" do
    it "supports create, update, and destroy for write users" do
      post "/api/v1/resources", headers: auth_headers(staff), params: { resource: { name: "Desk 1" } }
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Desk 1")

      resource_id = json["id"]
      patch "/api/v1/resources/#{resource_id}", headers: auth_headers(owner), params: { resource: { name: "Desk 2" } }
      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Desk 2")

      delete "/api/v1/resources/#{resource_id}", headers: auth_headers(owner)
      expect(response).to have_http_status(:no_content)
    end

    it "blocks read-only users from modifying resources" do
      post "/api/v1/resources", headers: auth_headers(read_only_user), params: { resource: { name: "Blocked" } }
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Read-only users cannot make changes.")
    end
  end

  describe "appointments" do
    it "creates an appointment with a service and resource" do
      post "/api/v1/appointments", headers: auth_headers(owner), params: {
        appointment: {
          client_id: client.id,
          resource_id: resource.id,
          scheduled_at: 4.days.from_now.iso8601,
          status: "scheduled",
          service_ids: [service.id]
        }
      }

      expect(response).to have_http_status(:created)
      expect(json["client_id"]).to eq(client.id)
      expect(json["services"]).to be_an(Array)
      expect(json["services"].first["title"]).to eq(service.title)
    end

    it "rejects overlapping appointments for the same resource" do
      existing = account.appointments.create!(scheduled_at: 5.days.from_now, status: "scheduled", user: owner, client: client, resource: resource)
      existing.services << service

      post "/api/v1/appointments", headers: auth_headers(owner), params: {
        appointment: {
          client_id: client.id,
          resource_id: resource.id,
          scheduled_at: (5.days.from_now + 15.minutes).iso8601,
          status: "scheduled",
          service_ids: [service.id]
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["errors"]).to include("Resource is already booked at the scheduled time")
    end

    it "prevents read-only users from creating appointments" do
      post "/api/v1/appointments", headers: auth_headers(read_only_user), params: {
        appointment: {
          client_id: client.id,
          resource_id: resource.id,
          scheduled_at: 6.days.from_now.iso8601,
          status: "scheduled",
          service_ids: [service.id]
        }
      }

      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Read-only users cannot make changes.")
    end
  end

  describe "services" do
    it "returns a list of services and allows updates" do
      get "/api/v1/services", headers: auth_headers(owner)
      expect(response).to have_http_status(:ok)
      expect(json).to be_an(Array)

      patch "/api/v1/services/#{service.id}", headers: auth_headers(owner), params: { service: { title: "Updated Consultation" } }
      expect(response).to have_http_status(:ok)
      expect(json["title"]).to eq("Updated Consultation")
    end

    it "blocks read-only users from deleting services" do
      delete "/api/v1/services/#{service.id}", headers: auth_headers(read_only_user)
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Read-only users cannot make changes.")
    end
  end
end
