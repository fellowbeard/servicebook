class ResourceSerializer
  def initialize(resource)
    @resource = resource
  end

  def as_json(*)
    {
      id: @resource.id,
      account_id: @resource.account_id,
      name: @resource.name
    }
  end
end