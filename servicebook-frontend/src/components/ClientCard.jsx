import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'

export default function ClientCard() {
  const { id } = useParams()

  const [client, setClient] = useState(null)
  const [noteBody, setNoteBody] = useState('')

  useEffect(() => {
    fetch(`/api/v1/clients/${id}`)
      .then((res) => res.json())
      .then((data) => setClient(data))
  }, [id])

  if (!client) return <p>Loading client...</p>

  function handleCreateAppointment() {
    console.log('new appointment for client:', client)
  }

  function handleAddNote(event) {
    event.preventDefault()

    console.log('new note:', {
      client_id: client.id,
      body: noteBody,
    })

    setNoteBody('')
  }

  return (
    <section className="client-card">
      <h2>
        {client.first_name} {client.last_name}
      </h2>


      <button onClick={handleCreateAppointment}>
        New Appointment
      </button>

      <h3>Service History</h3>
      <div>
        {client.services?.length > 0 ? (
          client.services.map((service) => (
            <div key={service.id}>
              <strong>{service.title}</strong>
              <p>{service.description}</p>
              <p>${service.price}</p>
              <p>{service.duration_minutes} minutes</p>
            </div>
          ))
        ) : (
          <p>No services yet.</p>
        )}
      </div>

      <h3>Notes</h3>
      <div>
        {client.notes?.length > 0 ? (
          client.notes.map((note) => (
            <p key={note.id}>{note.body}</p>
          ))
        ) : (
          <p>No notes yet.</p>
        )}
      </div>

      <form onSubmit={handleAddNote}>
        <label htmlFor={`note-${client.id}`}> Add note </label>

        <textarea
          id={`note-${client.id}`}
          value={noteBody}
          onChange={(event) => setNoteBody(event.target.value)}
        />

        <button type="submit">Save Note</button>
      </form>
    </section>
  )
}