# Classy CATE

## Geting Setup

The following steps will setup a dev environment, the last `jake` being optional to start the dev server...

    git clone https://github.com/LawrenceJones/classy-cate.git
    git checkout webapps
    npm install
    jake

## Deploying

Deployment takes place via a git push command. Taking the host `docvm.doc.ic.ac.uk` as an example...

    git remote add deploy ssh://USER@docvm.doc.ic.ac.uk:/home/web/classy
    git push deploy live:master

## Asset compilation

Jake is used to compile the assets, which will be located in `/public/js/app.js` and `/public/css/app.css` respectively.

    jake assets:compile


