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

In future, GitHub webhooks are probably the best method for operating an automated deploy, but
for the moment all that's required is a remote git server.

The process automates a switchover from the previous site version to the new. By setting the
production machine up with a bare git repo (a repo designed to be pushed to) we can trigger a
deployment process by having production listen for a push. The code to trigger the deploy is
inside a post-receive githook, while the deployment logic is inside the Jakefile.

Assuming you're on your production server, then a whistle-stop setup is...

    git clone https://github.com/LawrenceJones/classy-cate.git ~/classy
    mkdir -p /home/web/classy && cd /home/web/classy
    git init --bare
    rm -rf ./hooks && ln -s ~/classy/hooks ./hooks
    mkdir node_modules
    npm install -g jake forever coffee-script

The above clones this repo, then creates a directory to contain live site files at /home/web/classy.
This path is then configured as a bare git repo (see git documentation) which is used as a git remote.
The hooks are symlinked in from our cloned working directory, allowing use of our post-receive script.

A directory is also created to contain `node_modules` cache, and then a few tools are installed
globally that are required for the build process.

## Asset compilation

Jake is used to compile the assets, which will be located in `/public/js/app.js` and
`/public/css/app.css` respectively.

    jake assets:compile


