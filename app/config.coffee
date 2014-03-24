fs   = require 'fs'
path = require 'path'

root_dir = path.join (__dirname || process.cwd()), '..'

if fs.existsSync (creds = path.join root_dir, 'creds')
  [user, pass] = (fs.readFileSync creds, 'utf8').split '\n'

module.exports = config =
  express:
    IP:   '127.0.0.1'
    PORT: process.env.PORT || 4567
    # Assign secret
    SECRET: 'ser7y5K$234@jiode89sej898djoi'
  cate:
    USER: user
    PASS: pass
  mongodb:
    NAME: 'classy-cate'
    PORT: process.env.MONGODB_PORT || 27017
    HOST: process.env.MONGODB_HOST || 'localhost'
    MLAB: process.env.MONGOLAB_URI
  nodetime:
    ACCOUNT_KEY: process.env.NODETIME_ACCOUNT_KEY
  paths:
    root_dir:   root_dir
    public_dir: path.join root_dir, 'public'
    views_dir:  path.join root_dir, 'views'
    styles_dir: path.join root_dir, 'stylesheets'
    web_dir:    path.join root_dir, 'web'

  
