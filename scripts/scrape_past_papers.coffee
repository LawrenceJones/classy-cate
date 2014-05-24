#!/usr/bin/env coffee
read = require 'read'

PastPaperProxy = require '../app/exams/past_paper_proxy'

read {prompt: 'Enter college login:'}, (err, login) ->
  read {prompt: 'Enter password:', silent: true}, (err, pass) ->
    user = -> user: login, pass: pass
    done = PastPaperProxy.scrapeArchives user, undefined, true
    done.then (data) ->
      console.log 'Finished scraping of Past Papers.'
    done.catch (err) ->
      console.error 'Error occurred when scraping Past Papers.\n', err
    done.finally ->
      process.exit 0
