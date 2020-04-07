# example.io -> your domain name
# username -> your github name
# reponame -> your repository name
# run in the application root directory 
# bash deploy.sh

npm run generate

cd dist

echo "example.io" > CNAME

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:username/reponame.git master:gh-pages

cd ..
