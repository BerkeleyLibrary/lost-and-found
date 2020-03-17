## Lost-and-Found

The Lost-and-Found application is intended for internal use across the UC Berkeley library system. Turned in goods will be logged and tracked through this simple rails application.
More to come

# Local Testing
To run Lost and Found locally using Docker, use the following commands.

'''
# Startup your containers
docker-compose up --build -d
# wait for everything to spin up, then run your setup
# tasks, whatever those are. Here's a good start:
docker-compose run --rm rails assets:precompile db:create db:migrate

# View the site in the browser and confirm it works
open http://localhost:3000
'''