module Health

  # Checks on the health of critical application dependencies
  #
  # @see https://tools.ietf.org/id/draft-inadarei-api-health-check-01.html JSON Format
  # @see https://www.consul.io/docs/agent/checks.html StatusCode based on Consul
  class Check

    TEST_ID = '012158720'.freeze

    attr_reader :status
    attr_reader :details

    def initialize
      status = Status::PASS
      details = {}

      @status = status
      @details = details
    end

    def as_json(*)
      { status: status, details: details }
    end

    def http_status_code
      passing? ? 200 : 429
    end

    private

    def passing?
      status == Status::PASS
    end

  end
end
