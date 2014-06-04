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

## Configuring Deploy Remote

The deployment process works through git and githooks. In future, a github webhook would most likely be the best solution
for listening for a new commit, though for the moment it is implemented using githooks. The basic concept is to create
a remote git repo on your production server, and setup your remote repo to use the hooks/post-receive script.

Assuming you're on your production server, then a whistle-stop setup is...

    git clone https://github.com/LawrenceJones/classy-cate.git ~/classy
    mkdir -p /home/web/classy && cd /home/web/classy
    git init --bare
    rm -rf ./hooks && ln -s ~/classy/hooks ./hooks
    mkdir node_modules
    npm install -g jake forever coffee-script

The above clones this repo, then creates a directory to contain live site files at /home/web/classy. This path is then
configured as a bare git repo (see git documentation) which is used as a git remote. The hooks are symlinked in from our
cloned working directory, allowing use of our post-receive script.

This could be better achieved by curling the post-receive from githubs current head, but as of the moment the repo is
private.

A directory is also created to contain `node_modules` cache, and then a few tools are installed globally that are required
for the build process.

## Asset compilation

Jake is used to compile the assets, which will be located in `/public/js/app.js` and `/public/css/app.css` respectively.

    jake assets:compile


