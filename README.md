## Lost-and-Found

The Lost-and-Found application is intended for internal use across the UC Berkeley library system. Turned in goods will be logged and tracked through this simple rails application.

### Login
Lost and Found uses the Berkeley calnet system in order to manage approved users. Users of the Lost and Found app must be affiliated with UC Berkeley as either a Student, Staff, or faculty member and must also be granted access to the app through an administrator.

If you are unsure about your status as an approved user, please reach out to the current administrator Mark Marrow.

### Timeout
In addition to the standard timeout from Calnet Services, Lost and Found enforces a 1 hour session policy for users. After that time has expired, a user will be prompted to logout and login again if they would like to continue using the service.

### Roles
Lost and Found users are organized into 3 role categories:

- `User::ROLE_READ_ONLY`: A user that can search through found items.
- `User::ROLE_STAFF`: A user that can add found items, search for found items and view found item edit history.
- `User::ROLE_ADMIN`: A user that has access to all previous role privileges with the added ability to manage users, locations, item types and remove older items from the application.

### Adding a found item
To add a found item, navigate to the found items page. Once there, a user will be prompted to fill out valuable information on the item and the conditions under which it was found. All fields marked with a red '*' are required for the request to be performed.

### How to search for a found item
To search for found items, a user can navigate to the search form or the landing page of the application. By default, the application brings up all found items in the Lost and Found database. To narrow this search, a user can specify the item type, the location it may have been lost in, a time frame for when the item was found, as well as entering search terms that match the items description( A required field upon insertion).

### How to claim an item
Staff and Administrative users can edit information of a found item. This is necessary if an item is being claimed. Simply select the item, set it's status to "claimed", fill out who claimed said item, and submit the edit request.

### Removing old items
An administrative privilege that enables items before a certain date to be marked as purged. Removing them from the found item's search without forcing them to be 'claimed'.

### Viewing old and claimed items
An administrative privileged, the admin can view old items that were purged or claimed. History and status changes are available.

### Terminology
#### User role
The rank a user has that dictates the privileges they have in the application.

#### Managing Locations
The general location an item was turned into. Generally a Library admin office.

#### Managing Item Types
The type of item Found (A backpack, laptop, ect)

### Local Testing
To run Lost and Found locally using Docker, use the following commands.

```bash
# Build the Lost & Found container image
docker compose build

# Start the stack. You may optionally want to enable adminer (phpMyAdmin) and Selenium (for browser testing) by removing `--no-deps`.
docker compose up -d --no-deps app db

# Wait for the DB to start, then run setup tasks
docker compose exec app rake assets:precompile db:setup

# Add yourself as an admin. (Substitute your UID and name.  Quotes are required.)
docker compose exec app rake "setup:admin[313539,Dan Schmidt]"

# View the site in the browser and confirm it works
open http://localhost:3000
```
