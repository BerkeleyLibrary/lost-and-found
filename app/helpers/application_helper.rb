module ApplicationHelper

  def flash_class(level)
    case level
        when "notice" then "alert alert-info alert-dismissible fade show"
        when "success" then "alert alert-success alert-dismissible fade show"
        when "error" then "alert alert-error alert-dismissible fade show"
        when "alert" then "alert alert-danger alert-dismissible fade show"
    end
end

def user_active?
    flash[:alert] = 'Your account is not active. Please contact an administrator.' unless cookies[:active_user] == 'true' || cookies[:logout_required]
  return
  end

  def logo_link
    link_to(
      image_tag('UCB_logo.png', height: '30', alt: 'UC Berkeley Library'),
      'https://www.lib.berkeley.edu/',
      { id:'home_button',class: 'navbar-brand no-link-style' }
    )
  end


  def staff_web_link
    link_to(
      image_tag('staff_web.gif', alt: 'UC Berkeley Staff'),
      'http://www.lib.berkeley.edu/Staff/',
      { class: 'navbar-brand no-link-style' }
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

  def find_version_author_name(version)
    user = User.find_version_author(version) 
    user ? user.user_name : 'unknown'
  end

  def diff(content1, content2)
    changes = Diffy::Diff.new(content1, content2, 
                              include_plus_and_minus_in_html: true, 
                              include_diff_info: true)
    changes.to_s.present? ? changes.to_s(:html).html_safe : 'No Changes'
 end

end