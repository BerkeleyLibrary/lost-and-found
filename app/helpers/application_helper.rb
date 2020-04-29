module ApplicationHelper

  def login_link
    link_to 'CalNet Logout', logout_path, class: 'nav-link' if authenticated?
  end

  def logo_link
    link_to(
      image_tag('laf_logo.gif', alt: 'UC Berkeley Library Lost and Found'),
      '#',
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

  def footer_partial
    render  template: "layouts/footer"
  end

  def staff_nav
    render  template: "layouts/staff_nav"
  end

  def login_form
    render template: "forms/login"
  end

end
