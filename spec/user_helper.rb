require 'webmock'

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
