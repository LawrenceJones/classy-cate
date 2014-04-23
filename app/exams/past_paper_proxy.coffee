$q = require 'q'
# Require CATe tools
CateProxy = require '../cate/cate_proxy'
PastPaperParser = require './past_paper_parser'

# Mongoose access
mongoose = require 'mongoose'
Exam = mongoose.model 'Exam'

# This is the earliest parsable year of archives.
EARLIEST_ARCHIVE = 1999

# Returns an array of all the available archive years.
allArchives = ->
  now = new Date().getFullYear() - 1
  [EARLIEST_ARCHIVE..now].map (y) -> year: y

# Keep track of how frequently the database has been loaded
lastUpdated = null
EXPIRED = 24 * 60 * 60 * 1000

# Initialise the proxy with the past paper parser
class PastPaperProxy extends CateProxy

  # Given a decoded user function, will scrape all the available
  # past paper archives. It will then load the scraped data into
  # the CateExams database.
  scrapeArchives: (user, def = $q.defer()) ->
    # Make a request that will be delayed by 5 seconds, then all
    # requests will be randomly requested over a period of 10
    # seconds.
    req = @makeRequest allArchives(), user, 5, 10
    req.then (data) =>
      loaded = $q.all data.map (year) ->
        papers = Object.keys(year.papers).map (k) -> year.papers[k]
        Exam.loadPaper papers
      loaded.then ->
        console.log 'Exams database has been updated!'
        lastUpdated = Date.now()
        def.resolve()
      loaded.catch (err) ->
        console.error err
        def.reject err
    return def.promise

  # Calculates whether our cache has expired
  cacheExpired: ->
    !lastUpdated? || (Date.now() - lastUpdated) > EXPIRED

    
    
module.exports = new PastPaperProxy(PastPaperParser)

