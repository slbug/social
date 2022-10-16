module UnifiedResponseFormat
  private

  def respond(response, status = :ok)
    render(json: response, status: status)
  end

  def respond_success(messages:, data: {}, status: :ok)
    respond(
      {
        success: {
          messages: Array(messages),
          data: (data.is_a?(Hash) ? data : {})
        }
      },
      status
    )
  end

  def respond_error(messages:, data: {}, status: :bad_request)
    respond(
      {
        errors: {
          messages: Array(messages),
          data: (data.is_a?(Hash) ? data : {})
        }
      },
      status
    )
  end
end
