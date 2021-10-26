require 'rails_helper'

describe HomeController, type: :system do
  describe :health do
    it 'returns a health response' do
      visit(health_path)
      expect(page).to have_content('pass')
    end
  end
end
