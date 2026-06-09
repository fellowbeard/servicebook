import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import AppointmentForm from "./AppointmentForm.jsx";

export default function ClientCard({ currentUser }) {
  const { id } = useParams();

  const [client, setClient] = useState(null);
  const [noteBody, setNoteBody] = useState("");
  const [editingAppointment, setEditingAppointment] = useState(null);
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
          // sort appointments by scheduled_at (most recent first)
          [...client.appointments]
            .sort((a, b) => new Date(b.scheduled_at) - new Date(a.scheduled_at))
            .map((appointment) => (
              <button
                key={appointment.id}
                type="button"
                className="appointment-item"
                onClick={() => setEditingAppointment(appointment)}
              >
                <div className="appointment-meta">
                  <strong>
                    {new Date(appointment.scheduled_at).toLocaleString(undefined, {
                      weekday: "short",
                      month: "short",
                      day: "numeric",
                      year: "numeric",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </strong>
                </div>

                <div className="appointment-services">
                  {appointment.services && appointment.services.length > 0 ? (
                    appointment.services.map((svc) => (
                      <div key={svc.id} className="service-entry">
                        <div className="service-title">{svc.title}</div>
                        <div className="service-desc">{svc.description}</div>
                        <div className="service-meta">
                          <span>${svc.price}</span>
                          <span> • {svc.duration_minutes} minutes</span>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="service-entry">No services recorded for this appointment.</div>
                  )}
                </div>
              </button>
            ))
        ) : (
          <p>No services yet.</p>
        )}
      </div>

      {editingAppointment && (
        <AppointmentForm
          currentUser={currentUser}
          existingAppointment={editingAppointment}
          onAppointmentUpdated={() => {
            setEditingAppointment(null);
            // Refresh client data
            fetch(`/api/v1/clients/${id}`)
              .then((res) => res.json())
              .then((data) => setClient(data));
          }}
        />
      )}

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
