#! /usr/bin/env bash

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

PORT=${PORT}

echo "Using port defined in .env: $PORT"
echo

echo "Get all items"
curl -X GET http://127.0.0.1:$PORT/items && echo
echo

echo "Get a single item"
curl -X GET http://127.0.0.1:$PORT/items/1 && echo
echo

echo "Create a new item"
curl -X POST http://127.0.0.1:$PORT/items -H "Content-Type: application/json" \
    -d '{"id": 0, "name": "New Item", "description": "A newly created item"}' && echo
echo

echo "Update an existing item"
curl -X PUT http://127.0.0.1:$PORT/items/1 -H "Content-Type: application/json"\
    -d '{"id": 1, "name": "Updated Item", "description": "This item has been updated"}' && echo
echo

echo "Partially update an existing item"
curl -X PATCH http://127.0.0.1:$PORT/items/2 -H "Content-Type: application/json" \
    -d '{"name": "Patched Item Name"}' && echo
echo

echo "Delete an item"
curl -X DELETE http://127.0.0.1:$PORT/items/1 && echo
echo

echo "Get available methods for /items"
curl -X OPTIONS http://127.0.0.1:$PORT/items && echo
echo

echo "Get available methods for /items/{item_id}"
curl -X OPTIONS http://127.0.0.1:$PORT/items/2 && echo
echo

echo "Get headers for /items (HEAD request)"
curl -I HEAD http://127.0.0.1:$PORT/items && echo
