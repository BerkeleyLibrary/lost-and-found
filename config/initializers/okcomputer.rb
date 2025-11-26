# Health check configuration

OkComputer.logger = Rails.logger
OkComputer.check_in_parallel = true

# Ensure database migrations have been run.
OkComputer::Registry.register 'database-migrations', OkComputer::ActiveRecordMigrationsCheck.new
