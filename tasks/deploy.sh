#!/bin/bash

rm -rf public

echo "Building the site..."
# hugo build
hugo --source . --destination ./public --minify

echo "Deploying to the server..."
# -c (--checksum): skip rebuilt-but-unchanged files so they keep their old
# mtime on the server, keeping nginx's ETag ("mtime-size") stable.
rsync -avzc --delete public/ $1:$2
echo "Deployment complete."