ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production!") if Rails.env.production?
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

module RequestSpecHelper
  def auth_headers(user)
    { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" }
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include RequestSpecHelper, type: :request
end
