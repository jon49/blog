#!/bin/bash

echo "Building the site..."
# hugo build
hugo -s . -d ./public --minify

echo "Deploying to the server..."
rsync -avz --delete public/ $1:$2
echo "Deployment complete."