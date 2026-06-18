class ResourceSerializer
  def initialize(resource)
    @resource = resource
  end

  def as_json(*)
    {
      id: @resource.id,
      name: @resource.name,
    }
  end
end
