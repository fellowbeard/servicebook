import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function AppointmentForm({ currentUser, initialClientId = '' }) {
  const navigate = useNavigate()

  const [clients, setClients] = useState([])
  const [clientId, setClientId] = useState(initialClientId || '')
  const [scheduledAt, setScheduledAt] = useState('')

  const [newClient, setNewClient] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
  })

  const isNewClient = clientId === 'new'

  useEffect(() => {
    fetch(`/api/v1/users/${currentUser.id}/dashboard`)
      .then((res) => res.json())
      .then((data) => setClients(data.clients || []))
  }, [currentUser.id])

  function handleNewClientChange(event) {
    setNewClient({
      ...newClient,
      [event.target.name]: event.target.value,
    })
  }

  function createAppointment(selectedClientId) {
    return fetch('/api/v1/appointments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        appointment: {
          client_id: selectedClientId,
          scheduled_at: scheduledAt,
        },
      }),
    }).then((res) => res.json())
  }

  function handleSubmit(event) {
    event.preventDefault()

    if (isNewClient) {
      fetch('/api/v1/clients', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          client: newClient,
        }),
      })
        .then((res) => res.json())
        .then((createdClient) => {
          return createAppointment(createdClient.id).then(() => createdClient)
        })
        .then((createdClient) => {
          navigate(`/clients/${createdClient.id}`)
        })

      return
    }

    createAppointment(clientId).then(() => {
      navigate(`/clients/${clientId}`)
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <h2>New Appointment</h2>

      <label htmlFor="client">Client</label>
      <select
        id="client"
        value={clientId}
        onChange={(event) => setClientId(event.target.value)}
      >
        <option value="">Select a client</option>
        <option value="new">+ New Client</option>

        {clients.map((client) => (
          <option key={client.id} value={client.id}>
            {client.first_name} {client.last_name}
          </option>
        ))}
      </select>

      {isNewClient && (
        <div>
          <label htmlFor="first_name">First Name</label>
          <input
            id="first_name"
            name="first_name"
            value={newClient.first_name}
            onChange={handleNewClientChange}
          />

          <label htmlFor="last_name">Last Name</label>
          <input
            id="last_name"
            name="last_name"
            value={newClient.last_name}
            onChange={handleNewClientChange}
          />

          <label htmlFor="email">Email</label>
          <input
            id="email"
            name="email"
            type="email"
            value={newClient.email}
            onChange={handleNewClientChange}
          />

          <label htmlFor="phone">Phone</label>
          <input
            id="phone"
            name="phone"
            value={newClient.phone}
            onChange={handleNewClientChange}
          />
        </div>
      )}

      <label htmlFor="scheduled_at">Scheduled At</label>
      <input
        id="scheduled_at"
        type="datetime-local"
        value={scheduledAt}
        onChange={(event) => setScheduledAt(event.target.value)}
      />

      <button type="submit">Create Appointment</button>
    </form>
  )
}