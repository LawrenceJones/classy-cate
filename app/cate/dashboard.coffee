$ = require 'cheerio'
config = require '../config'
CateResource = require './resource'

# Retrives CATe version, ie. 7.1
getVersion = ($page) ->
  version = $page
    .elemAt('table', 0)
    .elemAt('td', 0)
    .text()

# Extracts the table of user information.
getInfoTbl = ($page) ->
  $infoTbl = $page
    .elemAt 'table', 2
    .elemAt 'table', 1

# Retrives the url of the students profile picture.
getProfilePic = ($page) ->
  profile_image_src = getInfoTbl($page)
    .elemAt 'tr', 0
    .find 'img'
    .attr 'src'

# Generates array of profile info fields.
getProfile = ($page) ->
  profile_fields = $page
    .elemAt 'table', 2
    .elemAt 'table', 1
    .elemAt 'tr', 1
    .find 'td'
    .map (i, e) -> $(e).text()

# Retrieves all available years, 2003 upward?
getAvailableYears = ($page) ->
  yearText = {}
  available_years = $page
    .find('select[name=newyear] option')[1..]
    .map (index, elem) =>
      val = $(elem)
        .attr('value')
        .match(/keyp=(\d+)/)[1]
      year = parseInt val, 10
      yearText[year] = $(elem).html()
  available_years = Object.keys yearText

# Extracts the 'Other Links' category.
getLinks = ($page) ->
  other_func_links = $page
    .elemAt 'table', 2
    .elemAt 'table', 9
    .find 'tr'
  hrefs = other_func_links.map (i, r) =>
    h = $(r).find('a').attr 'href'

# Parses student class, ie. C1.
getClass = ($page) ->
  klass = $page.find('input[name=class]:checked').val()
  period = $page.find('input[name=period]:checked').val()
  return klass: klass, period: period

# Retrives keyt, not sure if this is useful anymore.
getKeyt = ($page) ->
  keyt = $page.find('input[type=hidden]').val()

module.exports = class Dashboard extends CateResource

  parse: ($page) ->

    version = getVersion $page
    [
      first_name, last_name, login
      category, candidate_number, cid, personal_tutor
    ] = getProfile $page

    hrefs = getLinks $page

    grading_schema_link      =  hrefs[2]
    documentation_link       =  hrefs[3]
    extensions_link          =  hrefs[4]
    projects_portal_link     =  hrefs[6]
    individual_records_link  =  hrefs[8]
    
    classDetails = getClass $page
    [klass, period] = [classDetails.klass, classDetails.period]
    keyt = getKeyt $page
    profile = getProfile $page
    profile_image_src = getProfilePic $page
    available_years = getAvailableYears $page

    timetable_url =
      "/timetable.cgi?period=#{period}&class=#{klass}&keyt=#{keyt}"

    # Updates the cached current period.
    config.cate.cached_period = period

    @data =
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
      default_class: klass
      default_period: period
      year: keyt.match(/^(\d+):/)[1]
      keyt: keyt
      timetable_url: timetable_url

  @url: (req) ->
    'https://cate.doc.ic.ac.uk'

