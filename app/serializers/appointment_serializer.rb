class AppointmentSerializer
  def initialize(appointment)
    @appointment = appointment
  end

  def as_json(*)
    {
      id: @appointment.id,
      account_id: @appointment.account_id,
      user_id: @appointment.user_id,
      client_id: @appointment.client_id,
      client: ClientSerializer.new(@appointment.client).as_json,
      scheduled_at: @appointment.scheduled_at.strftime("%Y-%m-%dT%H:%M:%S"),
      status: @appointment.status,
      services: @appointment.services.map do |service|
        ServiceSerializer.new(service).as_json
      end
    }
  end
end