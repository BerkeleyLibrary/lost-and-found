require 'calnet_helper'

describe SessionsController, type: :request do
  it 'logs Omniauth parameters as JSON' do
    valid_user_id = '013191304'.freeze
    log = capturing_log { with_login(valid_user_id) { get home_path } }
    lines = log.lines

    expected_msg = 'Received omniauth callback'
    log_line = lines.find { |line| line.include?(expected_msg) }
    result = JSON.parse(log_line)
    expect(result['msg']).to eq(expected_msg)
    omniauth_hash = result['omniauth']
    expect(omniauth_hash['extra']['employeeNumber']).to eq(valid_user_id)
  end
end
