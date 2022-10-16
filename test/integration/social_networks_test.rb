require "test_helper"

class SocialNetworksTest < ActionDispatch::IntegrationTest
  test 'should be valid response without error messages' do
    RedisPool.get.with { |connection| connection.del(SocialNetworks::Fetcher::CACHE_KEY) }
    stubs = Faraday::Adapter::Test::Stubs.new

    stubs.get('/twitter') do
      [200, {}, '[{"username":"twitter","tweet":"twitter"}]']
    end

    stubs.get('/facebook') do
      [200, {}, '[{"name":"facebook","status":"facebook"}]']
    end

    stubs.get('/instagram') do
      [200, {}, '[{"username":"instagram","picture":"instagram"}]']
    end

    connection = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    SocialNetworks::Fetcher.stub_any_instance(:connection, connection) do
      get '/'

      assert_response :success
      assert_equal '{"success":{"messages":[],"data":{"twitter":[{"username":"twitter","tweet":"twitter"}],"facebook":[{"name":"facebook","status":"facebook"}],"instagram":[{"username":"instagram","picture":"instagram"}]}}}', @response.body
    end
  end

  test 'should be valid response with error messages when json is invalid' do
    RedisPool.get.with { |connection| connection.del(SocialNetworks::Fetcher::CACHE_KEY) }
    stubs = Faraday::Adapter::Test::Stubs.new

    stubs.get('/twitter') do
      [200, {}, 'oh']
    end

    stubs.get('/facebook') do
      [200, {}, '[{"name":"facebook","status":"facebook"}]']
    end

    stubs.get('/instagram') do
      [200, {}, '[{"username":"instagram","picture":"instagram"}]']
    end

    connection = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    SocialNetworks::Fetcher.stub_any_instance(:connection, connection) do
      get '/'

      assert_response :success
      assert_equal '{"success":{"messages":["Not valid JSON twitter response, showing cached data instead"],"data":{"twitter":[],"facebook":[{"name":"facebook","status":"facebook"}],"instagram":[{"username":"instagram","picture":"instagram"}]}}}', @response.body
    end
  end
end
