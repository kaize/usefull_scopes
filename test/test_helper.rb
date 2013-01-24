require 'bundler/setup'
require 'active_record'

Bundler.require

MiniTest::Unit.autorun

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
  t.timestamps
end

class User < ActiveRecord::Base
  include UsefullScopes
end

class TestCase < MiniTest::Unit::TestCase
  def load_fixture(filename)
    File.read(File.dirname(__FILE__) + "/fixtures/#{filename}")
  end
end
