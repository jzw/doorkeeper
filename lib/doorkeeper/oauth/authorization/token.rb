module Doorkeeper
  module OAuth
    module Authorization
      class Token
        attr_accessor :pre_auth, :resource_owner, :token

        def initialize(pre_auth, resource_owner)
          @pre_auth       = pre_auth
          @resource_owner = resource_owner
        end

        def self.access_token_expires_in(server, pre_auth)
          override_expiration = server.parameters[:expires_in]

          custom_expiration = server.
            custom_access_token_expires_in.call(pre_auth)

          if override_expiration
            override_expiration
          elsif custom_expiration
            custom_expiration
          else
            server.access_token_expires_in
          end
        end

        def issue_token
          @token ||= AccessToken.find_or_create_for(
            pre_auth.client,
            resource_owner.id,
            pre_auth.scopes,
            self.class.access_token_expires_in(configuration, pre_auth),
            false
          )
        end

        def native_redirect
          {
            controller: 'doorkeeper/token_info',
            action: :show,
            access_token: token.token
          }
        end

        def configuration
          Doorkeeper.configuration
        end
      end
    end
  end
end
