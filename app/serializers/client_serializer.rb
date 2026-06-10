class ClientSerializer
  def initialize(client)
    @client = client
  end

  def as_json(*)
    {
      id: @client.id,
      account_id: @client.account_id,
      user_id: @client.user_id,
      first_name: @client.first_name,
      last_name: @client.last_name,
      email: @client.email,
      phone: @client.phone 
    }
  end
end