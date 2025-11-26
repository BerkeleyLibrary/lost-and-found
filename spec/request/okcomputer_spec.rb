require 'rails_helper'

RSpec.describe 'OKComputer', type: :request do
  it 'is mounted at /okcomputer' do
    get '/okcomputer'
    expect(response).to have_http_status :ok
  end

  it 'returns all checks to /health' do
    get '/health'
    expect(response).to have_http_status :ok
    expect(response.parsed_body.keys).to match_array %w[
      default
      database
      database-migrations
    ]
  end
end
