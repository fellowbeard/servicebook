import { useEffect, useState } from 'react'

export default function UserDashboard({ currentUser }) {
  const [dashboard, setDashboard] = useState(null)

  useEffect(() => {
    fetch(`/api/v1/users/${currentUser.id}/dashboard`)
      .then((res) => res.json())
      .then((data) => setDashboard(data))
  }, [currentUser])

  if (!dashboard) return <p>Loading...</p>

  return (
    <main>
      <h1>Dashboard</h1>

      <h2>
        Welcome, {dashboard.user?.first_name} {dashboard.user?.last_name}
      </h2>

      <p>Appointments: {dashboard.appointments_count}</p>

      <h3>Recent Clients</h3>
      <div>
        {dashboard.recent_clients?.map((client) => (
          <div key={client.id}>
            {client.first_name} {client.last_name} — {client.email}
          </div>
        ))}
      </div>

      <h3>Recent Appointments</h3>
      <div>
        {dashboard.recent_appointments?.map((appointment) => (
          <div key={appointment.id}>
            {appointment.scheduled_at}
          </div>
        ))}
      </div>
    </main>
  )
}