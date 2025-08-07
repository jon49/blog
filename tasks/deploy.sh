#!/bin/bash

rm -rf public

echo "Building the site..."
# hugo build
hugo --source . --destination ./public --minify

echo "Deploying to the server..."
rsync -avz --delete public/ $1:$2
echo "Deployment complete."