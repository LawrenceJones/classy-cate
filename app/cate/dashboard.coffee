CateResource = require './resource'

class Dashboard extends CateResource

  getVersion: ->
    version = @$page
      .elemAt('table', 0)
      .elemAt('td', 0)
      .text()

  getInfoTbl: ->
    $infoTbl = @$page
      .elemAt 'table', 2
      .elemAt 'table', 1

  getProfilePic: ->
    profile_image_src = @getInfoTbl()
      .elemAt 'tr', 0
      .find 'img'
      .attr 'src'

  getProfile: ->
    profile_fields = @$page
      .elemAt 'table', 2
      .elemAt 'table', 1
      .elemAt 'tr', 1
      .find 'td'
      .map (i, e) => @$(e).text()

  getAvailableYears: ->
    yearText = {}
    available_years = @$page
      .find('select[name=newyear] option')[1..]
      .map (index, elem) =>
        val = @$(elem)
          .attr('value')
          .match(/keyp=(\d+)/)[1]
        year = parseInt val, 10
        yearText[year] = @$(elem).html()
    available_years = Object.keys yearText

  getLinks: ->
    other_func_links = @$page
      .elemAt 'table', 2
      .elemAt 'table', 9
      .find 'tr'

    hrefs = other_func_links.map (i, r) =>
      h = @$(r).find('a').attr 'href'

  getClass: ->
    klass = @$page.find('input[name=class]:checked').val()
    period = @$page.find('input[name=period]:checked').val()
    return klass: klass, period: period

  getKeyt: ->
    keyt = @$page.find('input[type=hidden]').val()

  parse: ->

    # current_url = document.URL
    # current_year = current_url.match("keyp=([0-9]+)")[1] #TODO: Error check
    # current_user = current_url.match("[0-9]+:(.*)")[1] # TODO: Error Check

    version = @getVersion()
    [
      first_name, last_name, login
      category, candidate_number, cid, personal_tutor
    ] = @getProfile()

    hrefs = @getLinks()

    grading_schema_link      =  hrefs[2]
    documentation_link       =  hrefs[3]
    extensions_link          =  hrefs[4]
    projects_portal_link     =  hrefs[6]
    individual_records_link  =  hrefs[8]
    
    classDetails = @getClass()
    [klass, period] = [classDetails.klass, classDetails.period]
    keyt = @getKeyt()
    profile = @getProfile()
    profile_image_src = @getProfilePic()
    available_years = @getAvailableYears()

    timetable_url =
      "/timetable.cgi?period=#{klass.period}&class=#{klass.klass}&keyt=#{keyt}"

    @data =
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
      default_class: klass
      default_period: period
      keyt: keyt
      timetable_url: timetable_url

  @url: (req) ->
    'https://cate.doc.ic.ac.uk'

module.exports = Dashboard

