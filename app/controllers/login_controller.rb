class LoginController < ApplicationController
  before_action :init_form!

  def index
    redirect_with_params(action: :new)
  end

  def create
    @form.submit!

    flash[:success] = t('.success', department_head_email: @form.department_head_email)
    redirect_with_params(action: :new)
  rescue Recaptcha::RecaptchaError
    flash[:danger] = t('.recaptcha')
    redirect_with_params(action: :new)
  rescue ActiveModel::ValidationError
    redirect_with_params(action: :new)
  end

  private

  def validate_recaptcha!
    verify_recaptcha!(model: @form)
  end
end
