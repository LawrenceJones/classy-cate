CateParser = require '../cate/cate_parser'

# Retrives CATe version, ie. 7.1
getVersion = ($) ->
  $('table:eq(0) td:eq(0)').text()

# Extracts the table of user information.
getInfoTbl = ($) ->
  $('table:eq(2) table:eq(1)')

# Retrives the url of the students profile picture.
getProfilePic = ($) ->
  getInfoTbl($)
    .find 'tr:eq(0) img'
    .attr 'src'

# Generates array of profile info fields.
getProfile = ($) ->
  $('table:eq(2) table:eq(1) tr:eq(1) td')
    .map (i, e) -> $(e).text()

# Retrieves all available years, 2003 upward?
getAvailableYears = ($) ->
  yearText = new Object()
  availableYears = $('select[name=newyear] option')[1..]
    .map (index, elem) ->
      val = $(elem)
        .attr('value')
        .match(/keyp=(\d+)/)[1]
      year = parseInt val, 10
      yearText[year] = $(elem).html()
  availableYears = Object.keys yearText

# Extracts the 'Other Links' category.
getLinks = ($) ->
  $('table:eq(2) table:eq(9) tr')
    .map (i, r) -> h = $(r).find('a').attr 'href'

# Parses student class, ie. C1.
getClass = ($) ->
  klass:  $('input[name=class]:checked').val()
  period: $('input[name=period]:checked').val()

# Retrives keyt, not sure if this is useful anymore.
getKeyt = ($) ->
  $('input[type=hidden]').val()

# Parses CATe Dashboard.
# Accepts data from ~/personal.cgi?keyp=<YEAR>:<USER>
module.exports = class DashboardParser extends CateParser

  # Extract user personal details from CATe dashboard page.
  extract: ($) ->

    [
      firstName, lastName, login
      category, candidateNumber, cid, personalTutor
    ] = getProfile $

    # Fetch links to various parts of CATe
    hrefs = getLinks $

    # Default period [1..9] and class ['c1'..]
    classDetails = getClass $

    # Find the keyt
    keyt = getKeyt $

    version: getVersion $
    profileImageSrc: getProfilePic $
    # User details table
    firstName: firstName
    lastName: lastName
    login: login
    category: category
    candidateNumber: candidateNumber
    cid: cid
    personalTutor: personalTutor
    # All years available for viewing
    availableYears: getAvailableYears $
    # Match against the hrefs
    # TODO - This doesn't take into account disabled links
    gradingSchemaLink:      hrefs[0]
    documentationLink:      hrefs[1]
    extensionsLink:         hrefs[2]
    projectsPortalLink:     hrefs[3]
    individualRecordsLink:  hrefs[4]
    # Info taken from the combo box
    defaultClass:   classDetails.klass
    defaultPeriod:  classDetails.period
    # Extracted from the keyt value
    year: keyt?.match?(/^(\d+):/)[1] || CateParser.defaultYear()
    keyt: keyt

  # Generates url from a user login and required year.
  @url: (query) ->
    year = query.year  ||  @defaultYear()
    if not year?
      throw Error 'Missing query parameters'
    "#{@CATE_DOMAIN}/personal.cgi?keyp=#{year}:"

