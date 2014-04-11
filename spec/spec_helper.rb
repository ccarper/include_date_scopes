require 'rubygems'
require 'timecop'
require 'rails/all'
require 'active_record'
require 'active_support'
require 'include_date_scopes'

if ActiveSupport::VERSION::MAJOR < 4
  require 'active_support/core_ext/logger'
end

Dir.glob(File.join(File.dirname(__FILE__), '{fixtures,matchers,support}', '*')) do |file|
  require file
end

if RUBY_PLATFORM == "java"
  database_adapter = "jdbcsqlite3"
else
  database_adapter = "sqlite3"
end

ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN
ActiveRecord::Base.establish_connection(
  :adapter  => database_adapter,
  :database => ':memory:'
)
ActiveRecord::Base.connection.create_table(:posts, :force => true) do |t|
  t.string :body
  t.timestamp :show_at
  t.timestamp :created_at
  t.timestamp :updated_at
  t.boolean :flag
end

ActiveRecord::Base.include IncludeDateScopes::DateScopes

# class Post < ActiveRecord::Base
# end


RSpec.configure do |config|

  config.mock_with :rspec

  config.after :each do
    Post.delete_all
  end
end

def define_model_class(name = "Post", parent_class_name = "ActiveRecord::Base", &block)
  Object.send(:remove_const, name) rescue nil
  eval("class #{name} < #{parent_class_name}; end", TOPLEVEL_BINDING)
  klass = eval(name, TOPLEVEL_BINDING)
  klass.class_eval do
    if respond_to?(:table_name=)
      self.table_name = 'posts'
    else
      set_table_name 'posts'
    end
  end
  klass.class_eval(&block) if block_given?
end
