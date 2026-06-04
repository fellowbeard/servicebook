import { useEffect, useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import ServiceForm from "./ServiceForm.jsx";

export default function UserDashboard({ currentUser }) {
  const [dashboard, setDashboard] = useState(null);
  const navigate = useNavigate();
  const [showServiceForm, setShowServiceForm] = useState(false);
  const [editingService, setEditingService] = useState(null);

  useEffect(() => {
    fetch(`/api/v1/users/${currentUser.id}/dashboard`)
      .then((res) => res.json())
      .then((data) => setDashboard(data));
  }, [currentUser.id]);

  function handleClientSelect(event) {
    const clientId = event.target.value;

    if (clientId) {
      navigate(`/clients/${clientId}`);
    }
  }

  function handleNewAppointment() {
    navigate("/appointments/new");
  }

  function handleNewClient() {
    navigate("/clients/new");
  }

  if (!dashboard) return <p>Loading...</p>;

  return (
    <main>
      <h1>Dashboard</h1>

      <h2>
        Welcome, {dashboard.user?.first_name} {dashboard.user?.last_name}
      </h2>

      <div>
        <button onClick={handleNewAppointment}>New Appointment</button>

        <button onClick={handleNewClient}>New Client</button>
      </div>

      <h3>Recent Clients</h3>
      <div>
        {dashboard.recent_clients?.map((client) => (
          <div key={client.id}>
            <Link to={`/clients/${client.id}`}>
              {client.first_name} {client.last_name}
            </Link>
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

      <button
        onClick={() => {
          setEditingService(null);
          setShowServiceForm(!showServiceForm);
        }}
      >
        {showServiceForm ? "Cancel" : "New Service"}
      </button>

      {showServiceForm && (
        <ServiceForm
          currentUser={currentUser}
          existingService={editingService}
          onServiceCreated={(createdService) => {
            setDashboard({
              ...dashboard,
              services: [...(dashboard.services || []), createdService],
            });

            setShowServiceForm(false);
          }}
          onServiceUpdated={(updatedService) => {
            setDashboard({
              ...dashboard,
              services: dashboard.services.map((service) =>
                service.id === updatedService.id ? updatedService : service
              ),
            });

            setEditingService(null);
            setShowServiceForm(false);
          }}
        />
      )}

      <h3>Services</h3>

      <div>
        {dashboard.services?.length > 0 ? (
          dashboard.services.map((service) => (
            <div key={service.id}>
              <strong>{service.title}</strong> — ${service.price} — {service.duration_minutes} minutes
              <button
                onClick={() => {
                  setEditingService(service);
                  setShowServiceForm(true);
                }}
              >
                Edit
              </button>
            </div>
          ))
        ) : (
          <p>No services yet.</p>
        )}
      </div>

      <h3>Recent Appointments</h3>
      <div>
        {dashboard.recent_appointments?.map((appointment) => (
          <div key={appointment.id}>{appointment.scheduled_at}</div>
        ))}
      </div>
    </main>
  );
}
