request = require 'request'
cheerio = require 'cheerio'
module.exports ?= {}

parseDashboard = ($, $page) ->

  # current_url = document.URL
  # current_year = current_url.match("keyp=([0-9]+)")[1] #TODO: Error check
  # current_user = current_url.match("[0-9]+:(.*)")[1] # TODO: Error Check
  
  version = $page
    .elemAt('table', 0)
    .elemAt('td', 0)
    .text()

  $infoTbl = $page
    .elemAt 'table', 2
    .elemAt 'table', 1

  profile_image_src = $infoTbl
    .elemAt 'tr', 0
    .find 'img'
    .attr 'src'

  profile_fields = $page
    .elemAt 'table', 2
    .elemAt 'table', 1
    .elemAt 'tr', 1
    .find 'td'
    .map (i, e) -> $(e).text()
  
  [
    first_name, last_name, login
    category, candidate_number, cid, personal_tutor
  ] = profile_fields

  yearText = {}
  available_years = $page.find('select[name=newyear] option')[1..].map (index, elem) ->
    year = parseInt $(elem).attr('value').match(/keyp=(\d+)/)[1], 10
    yearText[year] = $(elem).html()
  available_years = Object.keys yearText

  other_func_links = $page
    .elemAt 'table', 2
    .elemAt 'table', 9
    .find 'tr'

  hrefs = other_func_links.map (i, r) ->
    h = $(r).find('a').attr 'href'

  grading_schema_link      =  hrefs[2]
  documentation_link       =  hrefs[3]
  extensions_link          =  hrefs[4]
  projects_portal_link     =  hrefs[6]
  individual_records_link  =  hrefs[8]

  default_class = $page.find('input[name=class]:checked').val()
  default_period = $page.find('input[name=period]:checked').val()

  keyt = $page.find('input[type=hidden]').val()

  timetable_url = '/timetable.cgi?period=' + default_period + '&class=' + default_class + '&keyt=' + keyt

  details = {
    # current_url: current_url
    # current_year: current_year
    # current_user: current_user
    version: version
    profile_image_src: profile_image_src
    first_name: first_name
    last_name: last_name
    login: login
    category: category
    candidate_number: candidate_number
    cid: cid
    personal_tutor: personal_tutor
    available_years: available_years
    grading_schema_link: grading_schema_link
    documentation_link: documentation_link
    extensions_link: extensions_link
    projects_portal_link: projects_portal_link
    individual_records_link: individual_records_link
    default_class: default_class
    default_period: default_period
    keyt: keyt
    timetable_url: timetable_url
  }

# GET /api/dashboard
exports.getDashboard = (req, res) ->
  options =
    url: 'https://cate.doc.ic.ac.uk'
    auth: req.creds
  request options, (err, data, body) ->
    $ = cheerio.load body, {
      xmlMode: true
      lowerCaseTags:true
    }
    res.json parseDashboard $, $ 'body'


