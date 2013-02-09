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

    def test_like_by_result
      3.times { create :model }
      @model = Model.first

      assert_respond_to Model, :like_by_field_2

      @models = Model.like_by_field_2(@model.field_2[0..3])

      assert @models.any?
      assert_includes @models, @model

    end

    def test_like_by_condition
      3.times { create :model }
      @model = Model.first

      @models = Model.like_by_field_2(@model.field_2[0..3])

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        assert condition.expr.match "like"
      end

    end

    def test_ilike_by_result
      3.times { create :model }
      @model = Model.first

      assert_respond_to Model, :ilike_by_field_2

      #@models = Model.ilike_by_field_2(@model.field_2[0..3])

      #assert @models.any?
      #assert_includes @models, @model

    end

    def test_ilike_by_condition
      3.times { create :model }
      @model = Model.first

      @models = Model.ilike_by_field_2(@model.field_2[0..3])

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        assert_kind_of Arel::Nodes::Matches, condition.expr

        assert_kind_of Arel::Attributes::Attribute, condition.expr.left
        assert_equal :field_2, condition.expr.left.name
        assert_equal "stri%", condition.expr.right

      end

    end

    def test_desc_by_result
      3.times { create :model }
      @model = Model.first

      assert_respond_to Model, :desc_by

      @models = Model.desc_by(:field_1)

      assert @models.any?
    end

    def test_desc_by_condition_array_attrs
      3.times { create :model }
      @model = Model.first
      attrs = [:field_1, :field_2]

      @models = Model.desc_by(attrs)

      arel = @models.arel
      orders_conditions = arel.orders

      assert orders_conditions.any?

      orders_conditions.each_with_index do |condition, index|
        assert_kind_of Arel::Nodes::Descending, condition
        assert_kind_of Arel::Attributes::Attribute, condition.expr

        assert_equal attrs[index], condition.expr.name
      end
    end


    def test_desc_by_condition
      3.times { create :model }
      @model = Model.first

      @models = Model.desc_by(:field_1)

      arel = @models.arel
      orders_conditions = arel.orders

      assert orders_conditions.any?

      orders_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Descending, condition
        assert_kind_of Arel::Attributes::Attribute, condition.expr

        assert_equal :field_1, condition.expr.name
      end
    end

    def test_desc_by_incorrect_params
      3.times { create :model }
      @model = Model.first
      begin
      @models = Model.desc_by("field_1")
      rescue Exception => e
        assert_equal "Symbol or Array of symbols is expected", e.message
      end
    end

    def test_asc_by_result
      3.times { create :model }
      @model = Model.first

      assert_respond_to Model, :asc_by

      @models = Model.asc_by(:field_1)

      assert @models.any?
    end

    def test_asc_by_condition_array_attrs
      3.times { create :model }
      @model = Model.first
      attrs = [:field_1, :field_2]

      @models = Model.asc_by(attrs)

      arel = @models.arel
      orders_conditions = arel.orders

      assert orders_conditions.any?

      orders_conditions.each_with_index do |condition, index|
        assert_kind_of Arel::Nodes::Ascending, condition
        assert_kind_of Arel::Attributes::Attribute, condition.expr

        assert_equal attrs[index], condition.expr.name
      end
    end

    def test_asc_by_condition
      3.times { create :model }
      @model = Model.first

      @models = Model.asc_by(:field_1)

      arel = @models.arel
      orders_conditions = arel.orders

      assert orders_conditions.any?

      orders_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Ascending, condition
        assert_kind_of Arel::Attributes::Attribute, condition.expr

        assert_equal :field_1, condition.expr.name
      end
    end

    def test_asc_by_incorrect_params
      3.times { create :model }
      @model = Model.first
      begin
      @models = Model.asc_by("field_1")
      rescue Exception => e
        assert_equal "Symbol or Array of symbols is expected", e.message
      end
    end

    def test_more_or_equal_by_result
      3.times { create :model }
      @model = Model.last

      @models = Model.field_1_more_or_equal(@model.field_1)

      assert @models.any?
      assert @models.include?(@model)
    end

    def test_more_or_equal_by_condition
      3.times { create :model }
      @model = Model.first

      @models = Model.field_1_more_or_equal(@model.field_1)

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        assert_kind_of Arel::Nodes::GreaterThanOrEqual, condition.expr
        assert_equal @model.field_1, condition.expr.right
      end
    end

    def test_less_or_equal_by_result
      3.times { create :model }
      @model = Model.first

      @models = Model.field_1_less_or_equal(@model.field_1)

      assert @models.any?
      assert @models.include?(@model)
    end

    def test_less_or_equal_by_condition
      3.times { create :model }
      @model = Model.first

      @models = Model.field_1_less_or_equal(@model.field_1)

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        assert_kind_of Arel::Nodes::LessThanOrEqual, condition.expr
        assert_equal @model.field_1, condition.expr.right
      end
    end

    def test_more_than_condition_value
      3.times { create :model }
      @model = Model.first

      @models = Model.more_than({field_1: 1})

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        condition.expr.children.each do |condition_part|
          assert_kind_of Arel::Nodes::GreaterThan, condition_part

          assert_kind_of Arel::Attributes::Attribute, condition_part.left

          assert_equal :field_1, condition_part.left.name
          assert_equal 1, condition_part.right
        end
      end

    end

    def test_more_than_condition_ar_object
      3.times { create :model }
      @model = Model.first

      @models = Model.more_than(@model)

      ctx = @models.arel.as_json["ctx"]
      where_conditions = ctx.wheres

      assert where_conditions.any?

      where_conditions.each do |condition|
        assert_kind_of Arel::Nodes::Grouping, condition
        condition.expr.children.each do |condition_part|
          assert_kind_of Arel::Nodes::GreaterThan, condition_part

          assert_kind_of Arel::Attributes::Attribute, condition_part.left

          assert_equal :id, condition_part.left.name
          assert_equal 1, condition_part.right
        end
      end

    end

    def test_more_than_incorrect_params
      3.times { create :model }
      @model = Model.first
      begin
      @models = Model.more_than("field_1")
      rescue Exception => e
        assert_equal "Hash or AR object is expected", e.message
      end
    end

  end
end
