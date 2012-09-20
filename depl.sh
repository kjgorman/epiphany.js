cake build
coffee -c assets/js/*.coffee
git add -u
git commit -m "$1"
git push heroku master