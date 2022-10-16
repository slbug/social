class BaseAction
  def initialize(rails_controller)
    @rails_controller = rails_controller
  end

  def call
    process
    self
  end

  def success?
    !failure?
  end

  def failure?
    errors_status.present?
  end

  def success
    {
      messages: success_messages,
      data: success_data,
      status: success_status || :ok
    }
  end

  def errors
    {
      messages: errors_messages,
      data: errors_data,
      status: errors_status
    }
  end

  private

  attr_reader :rails_controller, :errors_status, :success_status

  delegate(:params, :request, :send_data, to: :rails_controller, private: true)
  delegate(:headers, to: :request, private: true)

  def process
    raise NotImplementedError
  end

  def success_messages
    @success_messages ||= []
  end

  def success_data
    @success_data ||= {}
  end

  def errors_messages
    @errors_messages ||= []
  end

  def errors_data
    @errors_data ||= {}
  end

  def success_with(messages: nil, data: {}, status: :ok)
    success_messages.concat(Array(messages))
    success_data.merge!(data) if data.is_a?(Hash)
    @success_status = status
  end

  def fail_with(messages:, data: {}, status: :unprocessable_entity)
    errors_messages.concat(Array(messages))
    errors_data.merge!(data) if data.is_a?(Hash)
    @errors_status = status
  end
end

