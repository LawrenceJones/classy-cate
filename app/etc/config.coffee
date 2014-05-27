fs   = require 'fs'
path = require 'path'

root_dir = path.join (__dirname || process.cwd()), '..', '..'
key_dir = path.join root_dir, 'keys'

if fs.existsSync (creds = '~/.imp')
  [user, pass] = (fs.readFileSync creds, 'utf8').split '\n'

secret_path = path.join(key_dir, 'secret.key')
if not fs.existsSync secret_path
  secret = (String.fromCharCode Math.floor(Math.random()*255)\
            for i in [1..2048])
              .filter (c) -> !/[\s\t\r\b\n]/.test c
              .join ''
  fs.writeFileSync secret_path, secret
  console.log 'Generated new secret key!'


module.exports = config =
  express:
    IP:   '127.0.0.1'
    PORT: process.env.PORT || 50000
    # Assign secret
    SECRET: (process.env.APP_SECRET ||
             fs.readFileSync path.join(key_dir, 'secret.key'))
  jwt:
    TOKEN_EXPIRY: 12 * 60
  cate:
    USER: user || process.env.CATE_USER
    PASS: pass || process.env.CATE_PASS
  users: new Object()
  mongodb:
    NAME: 'classy-cate'
    PORT: process.env.MONGODB_PORT || 27017
    HOST: process.env.MONGODB_HOST || 'localhost'
    MLAB: process.env.MONGOLAB_URI
  nodetime:
    appName:    process.env.NODETIME_APP_NAME || 'Doc Exams'
    accountKey: process.env.NODETIME_ACCOUNT_KEY
  paths:
    root_dir:   root_dir
    app_dir:    path.join root_dir, 'app'
    public_dir: path.join root_dir, 'public'
    views_dir:  path.join root_dir, 'views'
    styles_dir: path.join root_dir, 'stylesheets'
    web_dir:    path.join root_dir, 'web'
  exams_timestamp: null

  
