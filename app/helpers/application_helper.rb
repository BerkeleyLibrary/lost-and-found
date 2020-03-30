module ApplicationHelper

  def login_link
    link_to 'CalNet Logout', logout_path, class: 'nav-link' if authenticated?
  end

end
