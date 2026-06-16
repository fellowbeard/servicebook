class AppointmentSerializer
  def initialize(appointment)
    @appointment = appointment
  end

  def as_json(*)
    {
      id: @appointment.id,
      user_id: @appointment.user_id,
      client_id: @appointment.client_id,
      resource_id: @appointment.resource_id,
      client: ClientSerializer.new(@appointment.client).as_json,
      resource: serialized_resource,
      scheduled_at: @appointment.scheduled_at.strftime("%Y-%m-%dT%H:%M:%S"),
      status: @appointment.status,
      duration_minutes: @appointment[:duration_minutes],
      blocking_reservation_time: @appointment.blocking_reservation_time,
      uses_default_duration: @appointment.uses_default_duration?,
      services: @appointment.services.map do |service|
        ServiceSerializer.new(service).as_json
      end
    }
  end

  private

  def serialized_client
    return nil unless @appointment.client

    {
      id: @appointment.client.id,
      first_name: @appointment.client.first_name,
      last_name: @appointment.client.last_name
    }
  end

  def serialized_resource
    return nil unless @appointment.resource

    ResourceSerializer.new(@appointment.resource).as_json
  end
end