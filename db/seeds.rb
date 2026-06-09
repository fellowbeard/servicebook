require 'faker'

# Destroy existing records
AppointmentService.destroy_all
Appointment.destroy_all
Note.destroy_all
Service.destroy_all
Client.destroy_all
User.destroy_all
Account.destroy_all

# Account
account_one = Account.create!(
  business_name: "Jane Stuff's Stuff and Things"
)

account_two = Account.create!(
  business_name: "John Denver's Sing Songs and Stuff"
)

# Users
jane = User.create!(
  account: account_one,
  first_name: "Jane", 
  last_name: "Stuff", 
  email: "janestuff@example.com"
)

john = User.create!(
  account: account_two,
  first_name: "John", 
  last_name: "Denver", 
  email: "johndenver@example.com"
)

User.create!(
  account: jane.account,
  first_name: "Susette",
  last_name: "StaffReader",
  email: "susettestaffreader@example.com",
  role: "read_only"
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
deep_tissue = Service.create!(
  user: jane,
  title: "Deep Tissue Massage",
  description: "Focused deep tissue session for shoulder and back tension.",
  duration_minutes: 60,
  price: 95.00
)

custom_rug = Service.create!(
  user: jane,
  title: "Custom Rug Consultation",
  description: "Initial consultation for a custom tufted rug design.",
  duration_minutes: 45,
  price: 50.00
)

follow_up = Service.create!(
  user: john,
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
  service: deep_tissue
)

AppointmentService.create!(
  appointment: appointment_one,
  service: custom_rug
)

# Appointment 2: Custom Rug + Follow-up
AppointmentService.create!(
  appointment: appointment_two,
  service: custom_rug
)

AppointmentService.create!(
  appointment: appointment_two,
  service: follow_up
)

# Appointment 3: Follow-up + Deep Tissue
AppointmentService.create!(
  appointment: appointment_three,
  service: follow_up
)

AppointmentService.create!(
  appointment: appointment_three,
  service: deep_tissue
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