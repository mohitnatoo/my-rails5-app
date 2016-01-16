desc 'Ensure that code is not running in production environment'
task :not_production do
  raise 'do not run in production' if Rails.env.production?
end

desc 'Sets up the project by running migration and populating sample data'
task setup: [:environment, :not_production, 'db:drop', 'db:create', 'db:migrate'] do
  ["setup_sample_data"].each { |cmd| system "rake #{cmd}" }
end

def delete_all_records_from_all_tables
  ActiveRecord::Base.connection.schema_cache.clear!

  Dir.glob(Rails.root + 'app/models/*.rb').each { |file| require file }

  ActiveRecord::Base.descendants.each do |klass|
    klass.reset_column_information
    klass.delete_all
  end
end

desc 'Deletes all records and populates sample data'
task setup_sample_data: [:environment, :not_production] do
  create_user(email: 'sam1@example.com')
  create_user(email: 'sam2@example.com', alias: 'sammy2')
  create_user(email: 'sam3@example.com', alias: 'sammy3')
end

def create_user( options = {} )
  attributes = options.reverse_merge(default_user_attributes)
  User.create! attributes
end

def default_user_attributes
  @default_user_attributes ||= { email: 'sam@example.com',
                                 name: "Sam",
                                 alias: "sammy1" }
end
