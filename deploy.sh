make cleanAll && make static && make posts && hugo
echo "Please enter commit message."
read commit
git add -A && git commit -m "$commit"
git push origin master --force
git push origin `git subtree split --prefix=public master`:gh-pages --force
# git subtree push --prefix=public https://github.com/jon49/blog.git gh-pages
