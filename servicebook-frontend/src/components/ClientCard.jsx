import { useState, useEffect } from "react";

import { useParams, useNavigate } from "react-router-dom";

export default function ClientCard({ currentUser }) {
  const { id } = useParams();

  const [client, setClient] = useState(null);
  const [noteBody, setNoteBody] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetch(`/api/v1/clients/${id}`)
      .then((res) => res.json())
      .then((data) => setClient(data));
  }, [id]);

  if (!client) return <p>Loading client...</p>;

  function handleCreateAppointment() {
    navigate(`/appointments/new?client_id=${client.id}`);
  }

  function handleAddNote(event) {
    event.preventDefault();

    fetch("/api/v1/notes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        note: {
          client_id: client.id,
          user_id: currentUser.id,
          body: noteBody,
        },
      }),
    })
      .then((res) => res.json())
      .then((newNote) => {
        setClient({
          ...client,
          notes: [...(client.notes || []), newNote],
        });

        setNoteBody("");
      });
  }

  return (
    <section className="client-card">
      <h2>
        {client.first_name} {client.last_name}
      </h2>

      <button onClick={handleCreateAppointment}>New Appointment</button>

      <h3>Service History</h3>
      <div>
        {client.appointments?.length > 0 ? (
          client.appointments.map((appointment) => (
            <div key={appointment.id}>
              <strong>{appointment.title}</strong>
              <p>{appointment.description}</p>
              <p>${appointment.price}</p>
              <p>{appointment.duration_minutes} minutes</p>
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
            <div key={note.id}>
              <p>{note.body}</p>
              <small>
                {new Date(note.created_at).toLocaleString("en-US", {
                  month: "long",
                  day: "numeric",
                  year: "numeric",
                })}
              </small>
            </div>
          ))
        ) : (
          <p>No notes yet.</p>
        )}
      </div>

      <form onSubmit={handleAddNote}>
        <label htmlFor={`note-${client.id}`}> Add note </label>

        <textarea id={`note-${client.id}`} value={noteBody} onChange={(event) => setNoteBody(event.target.value)} />

        <button type="submit">Save Note</button>
      </form>
    </section>
  );
}
