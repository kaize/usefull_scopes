require 'test_helper'

module UsefullScopes
  class ScopesTest < TestCase
    def setup
    end

    def test_random
      assert_equal "SELECT \"users\".* FROM \"users\"  ORDER BY RANDOM()", User.random().to_sql
    end
  end
end
