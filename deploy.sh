make cleanAll && make static && make posts && hugo
echo "Please enter commit message."
read commit
git add -A && git commit -m "$commit"
git push origin +master
git subtree push --prefix=public https://github.com/jon49/blog.git gh-pages
