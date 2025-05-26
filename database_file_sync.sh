#!/bin/bash
# This script automates the database and file sync from live to test.

# Set variables
LIVE_DIR="/var/www/live"
TEST_DIR="/var/www/test"

# 1. Sync the database from live to test
echo "Syncing the database from live to test..."
drush sql-dump --result-file=/tmp/live_db.sql -r $LIVE_DIR
drush sql-cli < /tmp/live_db.sql -r $TEST_DIR

# 2. Sync files from live to test
echo "Syncing files from live to test..."
rsync -avz $LIVE_DIR/sites/default/files/ $TEST_DIR/sites/default/files/

echo "Database and file sync complete!"