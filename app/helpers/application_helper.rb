module ApplicationHelper

  def login_link
    link_to 'CalNet Logout', logout_path, class: 'nav-link' if authenticated?
  end

  def logo_link
    link_to(
      image_tag('UCB_logo.png', height: '30', alt: 'UC Berkeley Library'),
      '/home',
      { class: 'navbar-brand no-link-style' }
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


  def staff_nav
    render template: "layouts/staff_nav"
  end

  def login_form
    render template: "forms/login"
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