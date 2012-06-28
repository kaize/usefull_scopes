module UsefullScopes
  autoload :Version, 'usefull_scopes/version'
  extend ActiveSupport::Concern

  included do
    scope :random, order("RANDOM()")
    scope :exclude, lambda {|id_or_object|
      value = id_or_object.is_a?(ActiveRecord::Base) ? id_or_object.id : id_or_object
      return scoped unless value
      where("#{quoted_table_name}.id != ?", value)
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
    end
  end
end

