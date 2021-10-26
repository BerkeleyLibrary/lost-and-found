module ApplicationHelper

  BOOTSTRAP_ALERT_CLASSES = {"notice"=>"info", "success"=>"success", "error"=>"error", "alert"=>"danger"}

  def flash_class(level)
    return unless (alert_class = BOOTSTRAP_ALERT_CLASSES[level])

    "alert alert-#{alert_class} alert-dismissible fade show"
  end

  def history_claimed_map(value)
    return !value || value.blank? ? "unclaimed" : value
  end

  def logo_link
    link_to(
      image_tag('UCB_logo.png', height: '30', alt: 'UC Berkeley Library'),
      'https://www.lib.berkeley.edu/',
      { id: 'home_button', class: 'navbar-brand no-link-style' }
    )
  end

  def layouts_footer
    render template: "layouts/footer"
  end

  def layouts_nav
    render template: "layouts/app_nav"
  end

  def questions_link
    mail_to support_email, 'Questions?', class: 'support-email'
  end

  def status_codes(value)
    case value
    when 1 then 'Found'
    when 3 then 'Claimed'
    else ""
    end
  end

  def login_form
    render template: "forms/login"
  end

  def history_to_pst(value)
    value.present? ? value.in_time_zone("Pacific Time (US & Canada)").strftime("%m/%d/%Y %l:%M %P") : ""
  end

  def history_to_readable(value)
    value.present? ? value.strftime("%l:%M %P") : ""
  end

  def history_to_readable_day(value)
    value.present? ? value.strftime("%m/%d/%Y") : ""
  end

  def items_list
    render template: "items/new"
  end

  def items_all
    render template: "items/all"
  end

  def header(text)
    content_for(:header) { text.to_s }
  end

  def diff(content1, content2)
    changes = Diffy::Diff.new(content1, content2,
                              include_plus_and_minus_in_html: true,
                              include_diff_info: true)
    changes.to_s.present? ? changes.to_s(:html).html_safe : 'No Changes'
  end

end
