export default function AppointmentCalendar({ appointments = [] }) {
  const upcomingAppointments = appointments.filter((appointment) => {
    return new Date(appointment.scheduled_at) >= new Date();
  });

  return (
    <section>
      <h3>Calendar</h3>
      {upcomingAppointments.length > 0 ? (
        upcomingAppointments.map((appointment) => (
          <div key={appointment.id}>
            <strong>
              {new Date(appointment.scheduled_at).toLocaleString(undefined, {
                weekday: "short",
                month: "short",
                day: "numeric",
                hour: "2-digit",
                minute: "2-digit",
              })}
            </strong>
            <div>
              {appointment.services.length > 0 ? (
                appointment.services.map((service) => <span key={service.id}>{service.title} </span>)
              ) : (
                <span>No services recorded</span>
              )}
            </div>
          </div>
        ))
      ) : (
        <p>No upcoming appointments.</p>
      )}
    </section>
  );
}
