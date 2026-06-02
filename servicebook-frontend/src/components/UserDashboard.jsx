import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function UserDashboard({ currentUser }) {
  const [dashboard, setDashboard] = useState(null)
  const navigate = useNavigate()

  useEffect(() => {
    fetch(`/api/v1/users/${currentUser.id}/dashboard`)
      .then((res) => res.json())
      .then((data) => setDashboard(data))
  }, [currentUser.id])

  function handleClientSelect(event) {
    const clientId = event.target.value

    if (clientId) {
      navigate(`/clients/${clientId}`)
    }
  }

  if (!dashboard) return <p>Loading...</p>

  return (
    <main>
      <h1>Dashboard</h1>

      <h2>
        Welcome, {dashboard.user?.first_name} {dashboard.user?.last_name}
      </h2>

      <h3>Recent Clients</h3>
      <div>
        {dashboard.recent_clients?.map((client) => (
          <div key={client.id}>
            {client.first_name} {client.last_name} — {client.email}
          </div>
        ))}
      </div>

      <h3>Find Client</h3>
      <select defaultValue="" onChange={handleClientSelect}>
        <option value="" disabled>
          Select a client
        </option>

        {dashboard.clients?.map((client) => (
          <option key={client.id} value={client.id}>
            {client.first_name} {client.last_name}
          </option>
        ))}
      </select>

      <h3>Recent Appointments</h3>
      <div>
        {dashboard.recent_appointments?.map((appointment) => (
          <div key={appointment.id}>{appointment.scheduled_at}</div>
        ))}
      </div>
    </main>
  )
}