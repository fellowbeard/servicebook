class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    { 
      id: @user.id,
      role: @user.role,
      first_name: @user.first_name,
      last_name: @user.last_name,
      email: @user.email
    }
  end
end