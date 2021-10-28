# :nocov:
module ExceptionHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |error|
      logger.error(error)
      render :standard_error, status: :internal_server_error
    end

    rescue_from Error::ForbiddenError do |error|
      # this isn't really an error condition, it just means the user's
      # not authorized, so we don't need the full stack trace etc.
      logger.info(error.to_s)
      render :forbidden, status: :forbidden, locals: { exception: error }
    end

    rescue_from Error::UnauthorizedError do |error|
      # this isn't really an error condition, it just means the user's
      # not logged in, so we don't need the full stack trace etc.
      logger.info(error.to_s)
      redirect_to login_path(url: request.fullpath)
    end
  end
end
# :nocov:
