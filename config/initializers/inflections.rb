# TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'ID'
  inflect.acronym 'IPod'
  inflect.acronym 'MP3'
  inflect.acronym 'MRC'
  inflect.acronym 'UC'
  inflect.acronym 'UCPD'
end
