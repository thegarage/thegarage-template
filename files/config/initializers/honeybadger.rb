custom_env_filters = %w(
  HONEY_BADGER_API_KEY
  PGBACKUPS_URL
  HEROKU_POSTGRESQL_COBALT_URL
  DATABASE_URL
)

Honeybadger.configure do |config|
  config.api_key = ENV['HONEY_BADGER_API_KEY']
  config.params_filters.concat custom_env_filters
end
