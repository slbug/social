module SocialNetworks
  class IndexAction < BaseAction

    private

    def process
      fetcher = SocialNetworks::Fetcher.new
      if fetcher.call
        success_with(data: fetcher.data, messages: fetcher.messages)
      else
        fail_with(messages: fetcher.messages)
      end
    end
  end
end
