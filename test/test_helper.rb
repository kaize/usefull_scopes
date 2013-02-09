require 'bundler/setup'
require 'active_record'
require 'simplecov'
require 'coveralls'
Coveralls.wear!

ENV["COVERAGE"] = "true"
SimpleCov.start if ENV["COVERAGE"]

Bundler.require

MiniTest::Unit.autorun

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :models do |t|
  t.integer       :field_1
  t.string        :field_2
  t.boolean       :field_3
  t.timestamps
end

class Model < ActiveRecord::Base
  include UsefullScopes
end

class TestCase < MiniTest::Unit::TestCase
  def load_fixture(filename)
    File.read(File.dirname(__FILE__) + "/fixtures/#{filename}")
  end

  require 'factory_girl'
  FactoryGirl.reload

  include FactoryGirl::Syntax::Methods
end
