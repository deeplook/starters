#! /usr/bin/env bash

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it to run these tests."
    echo "On macOS: brew install jq"
    exit 1
fi

# Load environment variables from .env file
if [ -n "$MYAPP_ENV_PATH" ]; then
    if [ ! -f "$MYAPP_ENV_PATH" ]; then
        echo "Error: File specified by MYAPP_ENV_PATH does not exist: $MYAPP_ENV_PATH"
        exit 1
    fi
    export $(cat "$MYAPP_ENV_PATH" | grep -v '^#' | xargs)
fi

# Ensure a clean slate by deleting the old database file
DB_FILE=$(echo $MYAPP_DATABASE_URL | sed 's/sqlite:\/\///')
echo "Deleting old database file: $DB_FILE"
rm -f "$DB_FILE"


echo "Environment variables:"
echo "MYAPP_ENV_PATH: $MYAPP_ENV_PATH"
echo "MYAPP_PORT: $MYAPP_PORT"
echo "MYAPP_DATABASE_URL: $MYAPP_DATABASE_URL"


echo "Get all items (should be empty)"
curl -s -X GET http://127.0.0.1:$MYAPP_PORT/items


echo "Create a new item"
response=$(curl -s -X POST http://127.0.0.1:$MYAPP_PORT/items -H "Content-Type: application/json" \
    -d '{"name": "Test Item", "description": "A test item"}')
echo $response
item_id=$(echo $response | jq '.id')
echo "Created item with ID: $item_id"


echo "Get the new item"
curl -s -X GET http://127.0.0.1:$MYAPP_PORT/items/$item_id


echo "Update the item"
curl -s -X PUT http://127.0.0.1:$MYAPP_PORT/items/$item_id -H "Content-Type: application/json"\
    -d '{"name": "Updated Item", "description": "This item has been updated"}'


echo "Partially update the item"
curl -s -X PATCH http://127.0.0.1:$MYAPP_PORT/items/$item_id -H "Content-Type: application/json" \
    -d '{"name": "Patched Item Name"}'


echo "Delete the item"
curl -s -X DELETE http://127.0.0.1:$MYAPP_PORT/items/$item_id


echo "Verify the item was deleted"
curl -s -X GET http://127.0.0.1:$MYAPP_PORT/items/$item_id


echo "Get available methods for /items (OPTIONS)"
curl -s -i -X OPTIONS http://127.0.0.1:$MYAPP_PORT/items


echo "Get headers for /items (HEAD)"
curl -s --head http://127.0.0.1:$MYAPP_PORT/items
