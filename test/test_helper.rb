require 'bundler/setup'
Bundler.require
require 'active_record'

require 'coveralls'
Coveralls.wear!

ENV["COVERAGE"] = "true"
SimpleCov.start if ENV["COVERAGE"]

# reporters doesn't work with AS < 4 (see https://travis-ci.org/kaize/validates/jobs/28579079)
if defined?(ActiveSupport::VERSION) && ActiveSupport::VERSION::MAJOR >= 4
  require "minitest/reporters"
  Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
end

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.create_table :models do |t|
  t.integer       :field_1
  t.string        :field_2
  t.boolean       :field_3
  t.text          :field_4
  t.timestamps
end

class Model < ActiveRecord::Base
  include UsefullScopes
end

class TestCase < MiniTest::Test
  def load_fixture(filename)
    File.read(File.dirname(__FILE__) + "/fixtures/#{filename}")
  end

  require 'factory_girl'
  FactoryGirl.reload

  include FactoryGirl::Syntax::Methods
end

require 'minitest/autorun'
