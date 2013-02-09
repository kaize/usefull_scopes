require 'test_helper'

module UsefullScopes
  class ScopesTest < TestCase
    def setup
    end

    def test_random_order_condition
      random_request = Model.random

      request_arel = random_request.arel
      order = request_arel.order
      order_conditions = order.orders

      assert_includes order_conditions, "RANDOM()"
    end

    def test_random_sql
      random_request = Model.random

      assert_equal "SELECT \"models\".* FROM \"models\"  ORDER BY RANDOM()", random_request.to_sql
    end

    def test_exclude_result
      3.times { create :model }
      @model = Model.first
      @models = Model.exclude(@model)

      models_count = Model.count - 1

      assert_equal models_count, @models.count
    end

    def test_exclude_conditions
      3.times { create :model }
      @model = Model.first
      @models = Model.exclude(@model)

      request_arel = @models.arel
      condition = request_arel.where_clauses
      assert_equal 1, condition.count
      assert condition.first.match "NOT IN"
    end

    def test_with_result
      3.times { create :model }
      @model = Model.first
      @models = Model.with({field_1: @model.field_1})

      assert @models

      assert_includes @models, @model
    end

    def test_with_conditions
      3.times { create :model }
      @model = Model.first
      @models = Model.with({field_1: @model.field_1})

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        condition.children.each do |condition_part|
          assert_kind_of Arel::Nodes::Equality, condition_part
        end
      end
    end

    def test_with_incorrect_params
      3.times { create :model }
      @model = Model.first
      begin
      @models = Model.with("field_1 = #{@model.field_1}")
      rescue Exception => e
        assert_equal "Hash is expected", e.message
      end
    end

    def test_without_result
      3.times { create :model }
      @model = Model.first
      @models = Model.without({field_1: @model.field_1})

      assert @models

      assert @models.include?(@model) == false
    end

    def test_without_conditions
      3.times { create :model }
      @model = Model.first
      @models = Model.without({field_1: @model.field_1})

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        condition.expr.children.each do |condition_part|
          assert_kind_of Arel::Nodes::NotIn, condition_part

          assert_kind_of Arel::Attributes::Attribute, condition_part.left

          assert_equal :field_1, condition_part.left.name
          assert_equal 1, condition_part.right
        end
      end
    end

    def test_without_incorrect_params
      3.times { create :model }
      @model = Model.first
      begin
      @models = Model.without("field_1 = #{@model.field_1}")
      rescue Exception => e
        assert_equal "Hash is expected", e.message
      end
    end

  end
end
