require 'faker'

# Destroy existing records
AppointmentService.destroy_all
Appointment.destroy_all
Note.destroy_all
Service.destroy_all
Client.destroy_all
User.destroy_all

# Users
jane = User.create!(
  first_name: "Jane", 
  last_name: "Stuff", 
  email: "janestuff@example.com"
)

john = User.create!(
  first_name: "John", 
  last_name: "Denver", 
  email: "johndenver@example.com"
)

# Clients
client_one = Client.create!(
  user: jane,
  first_name: "Maya",
  last_name: "Rivera",
  email: "maya.rivera@example.com",
  phone: Faker::PhoneNumber.phone_number
)

client_two = Client.create!(
  user: jane,
  first_name: "Caleb",
  last_name: "Brooks",
  email: "caleb.brooks@example.com",
  phone: Faker::PhoneNumber.phone_number
)

client_three = Client.create!(
  user: john,
  first_name: "Nina",
  last_name: "Patel",
  email: "nina.patel@example.com",
  phone: Faker::PhoneNumber.phone_number
)

# Services
Service.create!(
  user: jane,
  client: client_one,
  title: "Deep Tissue Massage",
  description: "Focused deep tissue session for shoulder and back tension.",
  duration_minutes: 60,
  price: 95.00
)

Service.create!(
  user: jane,
  client: client_two,
  title: "Custom Rug Consultation",
  description: "Initial consultation for a custom tufted rug design.",
  duration_minutes: 45,
  price: 50.00
)

Service.create!(
  user: john,
  client: client_three,
  title: "Follow-up Appointment",
  description: "Follow-up service appointment and client check-in.",
  duration_minutes: 30,
  price: 40.00
)

# Appointments
appointment_one = Appointment.create!(
  client: client_one,
  scheduled_at: 2.days.from_now
)

appointment_two = Appointment.create!(
  client: client_two,
  scheduled_at: 4.days.from_now
)

appointment_three = Appointment.create!(
  client: client_three,
  scheduled_at: 1.week.from_now
)

# Appointment Services (join records)
# Appointment 1: Deep Tissue + Custom Rug
AppointmentService.create!(
  appointment: appointment_one,
  service: Service.find_by(title: "Deep Tissue Massage")
)

AppointmentService.create!(
  appointment: appointment_one,
  service: Service.find_by(title: "Custom Rug Consultation")
)

# Appointment 2: Custom Rug + Follow-up
AppointmentService.create!(
  appointment: appointment_two,
  service: Service.find_by(title: "Custom Rug Consultation")
)

AppointmentService.create!(
  appointment: appointment_two,
  service: Service.find_by(title: "Follow-up Appointment")
)

# Appointment 3: Follow-up + Deep Tissue
AppointmentService.create!(
  appointment: appointment_three,
  service: Service.find_by(title: "Follow-up Appointment")
)

AppointmentService.create!(
  appointment: appointment_three,
  service: Service.find_by(title: "Deep Tissue Massage")
)

# Notes
Note.create!(
  client: client_one,
  user: jane,
  body: "Client prefers afternoon appointments and firm pressure."
)

Note.create!(
  client: client_two,
  user: john,
  body: "Interested in earth tones and a bold geometric design."
)

Note.create!(
  client: client_three,
  user: jane,
  body: "Follow up about scheduling and preferred service length."
)