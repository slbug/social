module ActionProxy
  extend ActiveSupport::Concern

  module ClassMethods
    private

    def proxy_actions(actions:, namespace:)
      actions.each do |action_name|
        define_method(action_name) do
          respond_action("#{namespace}::#{action_name.to_s.camelize}Action".constantize.new(self).call)
        end
      end
    end
  end

  private

  def respond_action(action)
    action.success? ? respond_success(**action.success) : respond_error(**action.errors)
  end
end
