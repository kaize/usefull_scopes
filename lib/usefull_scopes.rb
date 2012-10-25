module UsefullScopes
  autoload :Version, 'usefull_scopes/version'
  extend ActiveSupport::Concern

  included do
    scope :random, order("RANDOM()")
    scope :exclude, lambda {|collection_or_object|
      collection = Array(collection_or_object)
      values = collection.map do |id_or_object|
        id_or_object.is_a?(ActiveRecord::Base) ? id_or_object.id : id_or_object
      end
      return scoped unless values.any?
      where("#{quoted_table_name}.id not in (?)", values)
    }

    attribute_names.each do |a|
      scope "by_#{a}", order("#{quoted_table_name}.#{a} DESC")
      scope "asc_by_#{a}", order("#{quoted_table_name}.#{a} ASC")

      scope "like_by_#{a}", lambda {|term|
        quoted_term = connection.quote(term + '%')
        where("lower(#{quoted_table_name}.#{a}) like #{quoted_term}")
      }
      scope "ilike_by_#{a}", lambda {|term|
        quoted_term = connection.quote(term + '%')
        where("#{quoted_table_name}.#{a} ilike #{quoted_term}")
      }

      scope "with_#{a}", lambda { |value| where("#{quoted_table_name}.#{a} = ?", value) }
      scope "without_#{a}", where("#{quoted_table_name}.#{a} IS NULL")
    end
  end
end

