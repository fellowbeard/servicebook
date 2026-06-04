class AppointmentSerializer
  def initialize(appointment)
    @appointment = appointment
  end

  def as_json(*)
    {
      id: @appointment.id,
      client_id: @appointment.client_id,
      scheduled_at: @appointment.scheduled_at,

      services: @appointment.services.map do |service|
        ServiceSerializer.new(service).as_json
      end
    }
  end
end