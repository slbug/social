class SocialNetworksController < ApplicationController
  proxy_actions(actions: %i[index], namespace: ::SocialNetworks)
end
