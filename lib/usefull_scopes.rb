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
      where("#{quoted_table_name}.id not in (?)", values)
    }

    scope :with, lambda {|attrs_hash|
      case attrs_hash
      when Hash
        where(attrs_hash)
      else
        raise TypeError, "Hash is expected"
      end
    }

    scope :without, lambda {|*attrs|
      attrs_hash = attrs.extract_options!
      query_params = []

      attrs.each do |attr_name|
        query_params << "#{quoted_table_name}.#{attr_name} IS NULL"
      end

      attrs_hash.each do |attr_name, attr_value|
        query_params << "#{quoted_table_name}.#{attr_name} NOT IN (:#{attr_name})"
      end

      return scoped if query_params.blank?
      where query_params.join(" AND "), attrs_hash
    }

    attribute_names.each do |a|
      scope "by_#{a}", order("#{quoted_table_name}.#{a} DESC")

      scope "asc_by_#{a}", order("#{quoted_table_name}.#{a} ASC")

      scope "like_by_#{a}", ->(term) {
        quoted_term = connection.quote(term + '%')
        where("lower(#{quoted_table_name}.#{a}) like #{quoted_term}")
      }

      scope "ilike_by_#{a}", ->(term) {
        quoted_term = connection.quote(term + '%')
        where("#{quoted_table_name}.#{a} ilike #{quoted_term}")
      }

      scope "#{a}_more", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where("#{quoted_table_name}.#{a} > #{value}")
      }

      scope "#{a}_less", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where("#{quoted_table_name}.#{a} < #{value}")
      }

      scope "#{a}_more_or_equal", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where("#{quoted_table_name}.#{a} >= #{value}")
      }

      scope "#{a}_less_or_equal", ->(value_or_object) {
        value = find_object_value_or_value(value_or_object, a)
        where("#{quoted_table_name}.#{a} <= #{value}")
      }
    end

    def self.find_object_value_or_value(value_or_object, field = "id")
      value = value_or_object.is_a?(ActiveRecord::Base) ? value_or_object.send(field) : value_or_object
      connection.quote(value) if columns_hash[field].type != :integer
    end
  end
end

