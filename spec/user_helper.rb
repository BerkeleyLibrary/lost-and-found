require 'webmock'

def stub_patron_dump(patron_id, status: 200, body: nil)
  escaped_id      = Patron::Dump.escape_patron_id(patron_id)
  patron_dump_url = "https://dev-oskicatp.berkeley.edu:54620/PATRONAPI/#{escaped_id}/dump"
  stub_request(:get, patron_dump_url).to_return(
    status: status,
    body: body || begin
      body_file = "spec/data/patrons/#{escaped_id}.txt"
      raise IOError, "No such file: #{body_file}" unless File.file?(body_file)

      File.new(body_file)
    end
  )
end

def all_patron_ids
  Dir.entries('spec/data/patrons').select { |f| f =~ /[0-9]+\.txt/ }.map { |f| f.match(/([0-9]+)/)[0] }
end



module MockUser
  ADMIN_ID = '013191304'.freeze

  class Type
    class << self
      def name_of(code)
        const = Type.constants.find { |c| Type.const_get(c) == code }
        const.to_s if const
      end

      def all
        Type.constants.map { |const| Type.const_get(const) }
      end

    end
  end
end
