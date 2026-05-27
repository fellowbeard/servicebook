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
  first_name: "Maya",
  last_name: "Rivera",
  email: "maya.rivera@example.com"
)

client_two = Client.create!(
  first_name: "Caleb",
  last_name: "Brooks",
  email: "caleb.brooks@example.com"
)

client_three = Client.create!(
  first_name: "Nina",
  last_name: "Patel",
  email: "nina.patel@example.com"
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
Appointment.create!(
  client: client_one,
  service: "Deep Tissue Massage",
  scheduled_at: 2.days.from_now
)

Appointment.create!(
  client: client_two,
  service: "Custom Rug Consultation",
  scheduled_at: 4.days.from_now
)

Appointment.create!(
  client: client_three,
  service: "Follow-up Appointment",
  scheduled_at: 1.week.from_now
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