module SocialNetworks
  class Fetcher < BaseService
    attr_reader :data, :messages

    BASE_URL = 'https://takehome.io'

    URLS = {
      twitter: '/twitter',
      facebook: '/facebook',
      instagram: '/instagram'
    }

    CACHE_KEY = 'social_networks'

    def initialize
      @connection = Faraday.new(url: BASE_URL, request: { timeout: 1 })
      @messages = []
    end

    def call
      @data = cached_data.symbolize_keys
      fetch

      cache_data!
    end

    private

    attr_reader :connection

    def fetch
      responses = {}

      connection.in_parallel do
        URLS.each do |network, url|
          responses[network] = connection.get(url)
        end
      end

      responses.each do |network, response|
        if !response.success?
          @messages << "Error #{response.status} while getting #{network} response, showing cached data instead"
          next
        end

        begin
          @data[network] = JSON.parse(response.body)
        rescue JSON::ParserError
          @messages << "Not valid JSON #{network} response, showing cached data instead"
        end
      end
    end

    def cached_data
      JSON.parse(RedisPool.get.with { |connection| connection.get(CACHE_KEY) }.to_s)
    rescue JSON::ParserError
      { twitter: [], facebook: [], instagram: [] }
    end

    def cache_data!
      RedisPool.get.with { |connection| connection.set(CACHE_KEY, data.to_json) }
    end
  end
end
