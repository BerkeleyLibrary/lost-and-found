module ExceptionHandling
  extend ActiveSupport::Concern

  included do

    rescue_from StandardError do |error|
      logger.error(error)
      render :standard_error, status: :internal_server_error
    end

    rescue_from Error::UnauthorizedError do |error|
      logger.error(error)
      redirect_to login_path(url: request.fullpath)
    end

    rescue_from Error::ForbiddenError do |error|
      logger.error(error)
      render :forbidden, status: :forbidden
    end

  end
end
