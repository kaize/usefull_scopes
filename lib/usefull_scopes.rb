module UsefullScopes
  autoload :Version, 'usefull_scopes/version'
  extend ActiveSupport::Concern

  included do
    scope :random, order("RANDOM()")

    scope :exclude, ->(collection_or_object) {
      collection = Array(collection_or_object)
      values = collection.map do |id_or_object|
        find_object_value_or_value(id_or_object)
      end
      return scoped unless values.any?
      where(arel_table[:id].not_in(values))
    }

    scope :with, ->(attrs_hash) {
      case attrs_hash
      when Hash
        where(attrs_hash)
      else
        raise TypeError, "Hash is expected"
      end
    }

    scope :without, ->(*attrs) {
      attrs_hash = attrs.extract_options!
      query_params = []

      attrs.each do |attr_name|
        query_params << arel_table[attr_name].eq(nil)
      end

      attrs_hash.each do |attr_name, attr_value|
        query_params << arel_table[attr_name].not_in(attr_value)
      end

      return scoped if query_params.blank?

      where arel_table.create_and query_params
    }

    attribute_names.each do |a|
      a = a.to_sym

      scope "by_#{a}", order(arel_table[a].desc)

      scope "asc_by_#{a}", order(arel_table[a].asc)

      scope "like_by_#{a}", ->(term) {
        quoted_term = connection.quote(term + '%')
        where("lower(#{quoted_table_name}.#{a}) like #{quoted_term}")
      }

      scope "ilike_by_#{a}", ->(term) {
        quoted_term = term + '%'
        where(arel_table[a].matches(quoted_term))
      }

      scope "#{a}_more", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where(arel_table[a].gt(value))
      }

      scope "#{a}_less", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where(arel_table[a].lt(value))
      }

      scope "#{a}_more_or_equal", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where(arel_table[a].gteq(value))
      }

      scope "#{a}_less_or_equal", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where(arel_table[a].lteq(value))
      }
    end

    def self.find_object_value_or_value(value_or_object, field = :id)
      value_or_object.is_a?(ActiveRecord::Base) ? value_or_object.send(field) : value_or_object
    end
  end
end

