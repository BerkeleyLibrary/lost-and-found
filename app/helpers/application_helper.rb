module ApplicationHelper

  BOOTSTRAP_ALERT_CLASSES = { 'notice' => 'info', 'success' => 'success', 'error' => 'error', 'alert' => 'danger' }.freeze

  def flash_class(level)
    return unless (alert_class = BOOTSTRAP_ALERT_CLASSES[level])

    "alert alert-#{alert_class} alert-dismissible fade show"
  end

  def logo_link
    link_to(
      image_tag('UCB_logo.png', height: '30', alt: 'UC Berkeley Library'),
      'https://www.lib.berkeley.edu/',
      { id: 'home_button', class: 'navbar-brand no-link-style' }
    )
  end

  def layouts_footer
    render template: 'layouts/footer'
  end

  def layouts_nav
    render template: 'layouts/app_nav'
  end

  def questions_link
    mail_to support_email, 'Questions?', class: 'support-email'
  end

  # TODO: use Rails i18n
  def format_history_value(attr, value)
    return 'unclaimed' if attr == 'claimed_by' && value.blank?
    return value.strftime('%l:%M %P') if attr == 'datetime_found' && value.present?
    return value.strftime('%m/%d/%Y') if attr == 'date_found' && value.present?

    value
  end

end
