class ServiceSerializer
  def initialize(service)
    @service = service
  end

  def as_json(*)
    {
      id: @service.id,
      user_id: @service.user_id,
      title: @service.title,
      price: @service.price,
      duration_minutes: @service.duration_minutes,
      description: @service.description
    }
  end
end