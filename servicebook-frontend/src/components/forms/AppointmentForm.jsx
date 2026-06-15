import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { authHeaders } from "../../utils/authHeaders.js";

export default function AppointmentForm({
  currentUser,
  initialClientId = "",
  existingAppointment = null,
  onAppointmentUpdated,
}) {
  const navigate = useNavigate();
  const isEditing = Boolean(existingAppointment);

  const [services, setServices] = useState([]);
  const [selectedServiceIds, setSelectedServiceIds] = useState(
    existingAppointment?.services?.map((service) => service.id) || []
  );

  const [resources, setResources] = useState([]);
  const [resourceId, setResourceId] = useState(existingAppointment?.resource_id || "");
  const [durationMinutes, setDurationMinutes] = useState(existingAppointment?.duration_minutes || "");

  const [clients, setClients] = useState([]);
  const [clientId, setClientId] = useState(existingAppointment?.client_id || initialClientId || "");

  const [scheduledAt, setScheduledAt] = useState(existingAppointment?.scheduled_at || "");

  const [status, setStatus] = useState(existingAppointment?.status || "scheduled");

  const [newClient, setNewClient] = useState({
    first_name: "",
    last_name: "",
    email: "",
    phone: "",
  });

  const isNewClient = clientId === "new";

  useEffect(() => {
    fetch(`/api/v1/users/${currentUser.id}/dashboard`, {
      headers: authHeaders(),
    })
      .then((res) => res.json())
      .then((data) => setClients(data.clients || []));

    fetch("/api/v1/services", {
      headers: authHeaders(),
    })
      .then((res) => res.json())
      .then((data) => setServices(data));

    fetch("/api/v1/resources", {
      headers: authHeaders(),
    })
      .then((res) => res.json())
      .then((data) => setResources(data));
  }, [currentUser.id]);

  function handleNewClientChange(event) {
    setNewClient({
      ...newClient,
      [event.target.name]: event.target.value,
    });
  }

  function saveAppointment(selectedClientId) {
    const url = isEditing ? `/api/v1/appointments/${existingAppointment.id}` : "/api/v1/appointments";

    const method = isEditing ? "PATCH" : "POST";

    return fetch(url, {
      method,
      headers: authHeaders(),
      body: JSON.stringify({
        appointment: {
          client_id: selectedClientId,
          resource_id: resourceId,
          scheduled_at: scheduledAt,
          status,
          duration_minutes: durationMinutes || null,
          service_ids: selectedServiceIds,
        },
      }),
    }).then((res) => res.json());
  }

  function handleSubmit(event) {
    event.preventDefault();

    if (isNewClient) {
      fetch("/api/v1/clients", {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify({
          client: {
            ...newClient,
            user_id: currentUser.id,
          },
        }),
      })
        .then((res) => res.json())
        .then((createdClient) => {
          return saveAppointment(createdClient.id).then(() => createdClient);
        })
        .then((createdClient) => {
          navigate(`/clients/${createdClient.id}`);
        });

      return;
    }

    saveAppointment(clientId).then(() => {
      if (isEditing && onAppointmentUpdated) {
        onAppointmentUpdated();
      } else {
        navigate(`/clients/${clientId}`);
      }
    });
  }

  const selectedServices = services.filter((service) => selectedServiceIds.includes(service.id));
  const selectedServiceDurationTotal = selectedServices.reduce(
    (total, service) => total + Number(service.duration_minutes || 0),
    0
  );

  const usesDefaultDuration =
    durationMinutes === "" && selectedServices.length > 0 && selectedServiceDurationTotal === 0;

  return (
    <form onSubmit={handleSubmit}>
      <h2>{isEditing ? "Edit Appointment" : "New Appointment"}</h2>

      <label htmlFor="client">Client</label>
      <select id="client" value={clientId} onChange={(event) => setClientId(event.target.value)}>
        <option value="">Select a client</option>

        {!isEditing && <option value="new">+ New Client</option>}

        {clients.map((client) => (
          <option key={client.id} value={client.id}>
            {client.first_name} {client.last_name}
          </option>
        ))}
      </select>

      {isNewClient && (
        <div>
          <label htmlFor="first_name">First Name</label>
          <input id="first_name" name="first_name" value={newClient.first_name} onChange={handleNewClientChange} />

          <label htmlFor="last_name">Last Name</label>
          <input id="last_name" name="last_name" value={newClient.last_name} onChange={handleNewClientChange} />

          <label htmlFor="email">Email</label>
          <input id="email" name="email" type="email" value={newClient.email} onChange={handleNewClientChange} />

          <label htmlFor="phone">Phone</label>
          <input id="phone" name="phone" value={newClient.phone} onChange={handleNewClientChange} />
        </div>
      )}

      <h3>Services</h3>

      {services.map((service) => (
        <label key={service.id}>
          <input
            type="checkbox"
            checked={selectedServiceIds.includes(service.id)}
            onChange={() => {
              if (selectedServiceIds.includes(service.id)) {
                setSelectedServiceIds(selectedServiceIds.filter((id) => id !== service.id));
              } else {
                setSelectedServiceIds([...selectedServiceIds, service.id]);
              }
            }}
          />
          {service.title} - ${service.price} - {service.duration_minutes || 0} min
        </label>
      ))}

      <label htmlFor="scheduled_at">Scheduled At</label>
      <input
        id="scheduled_at"
        type="datetime-local"
        value={scheduledAt}
        onChange={(event) => setScheduledAt(event.target.value)}
      />

      <label htmlFor="resource">Resource</label>
      <select id="resource" value={resourceId} onChange={(event) => setResourceId(event.target.value)}>
        <option value="">Select a resource</option>

        {resources.map((resource) => (
          <option key={resource.id} value={resource.id}>
            {resource.name}
          </option>
        ))}
      </select>

      <label htmlFor="duration_minutes">Duration Override Minutes</label>
      <input
        id="duration_minutes"
        type="number"
        min="1"
        value={durationMinutes}
        onChange={(event) => setDurationMinutes(event.target.value)}
        placeholder="Leave blank to use service duration"
      />

      {usesDefaultDuration && (
        <p className="warning">
          This appointment has no service duration. ServiceBook will reserve the resource for 60 minutes unless you
          enter a custom duration.
        </p>
      )}

      {isEditing && (
        <>
          <label htmlFor="status">Status</label>
          <select id="status" value={status} onChange={(event) => setStatus(event.target.value)}>
            <option value="scheduled">Scheduled</option>
            <option value="completed">Completed</option>
            <option value="canceled">Canceled</option>
          </select>
        </>
      )}

      <button type="submit">{isEditing ? "Update Appointment" : "Create Appointment"}</button>
    </form>
  );
}
