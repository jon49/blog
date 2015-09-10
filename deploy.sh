read -p "Please enter commit message." commit
make cleanAll && make posts && hugo && \
git add -A && git commit -m "$commit" && \
git subtree push --prefix=public https://github.com/jon49/blog.git gh-pages
