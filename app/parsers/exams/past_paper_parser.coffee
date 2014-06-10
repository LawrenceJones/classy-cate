HTMLParser = require '../html_parser'

# Parses data about past papers from a past paper indexing page.
# Accepts data from https://exams.doc.ic.ac.uk/pastpapers/papers.<YEAR-YEAR>
module.exports = class PastPaperParser extends HTMLParser

  # Extract all past papers from an index page.
  # Example index page is https://exams.doc.ic.ac.uk/pastpapers/papers.09-10
  extract: ($) ->

    # Select the first header for start of iteration
    $node = $('h1:eq(0)')
    groups = new Object()
    currentClass = null

    # Collect all papers into this object.
    # Ex. 'C214': { id: 'C214', year: 2014
    #               title: 'Operating...'
    #               link: '...', classes: [] }
    papers = new Object()

    # While we don't encounter the 'By class' header, keep moving
    while $node.length > 0 && !/By class/.test $node.html()
      $node = $node.next()

    # While we haven't yet hit the 'Complete' list of exams, parse a paper
    while ($node = $node.next()).length > 0 && !/^Complete/.test $node.text()
      if $node.is 'h3'
        currentClass = $node.text()
      else if ($a = $node.find('a')).length > 0
        [id, title] = $a.text().split ': '
        paper = (papers[id] ?= id: id, title: title, year: @query.year)
        paper.url = "#{@url}/#{$a.attr 'href'}"
        (paper.classes ?= []).addUnique currentClass

    # Return the collection of papers
    year:   @query.year
    papers: papers

  # Simply requires a year for parsing.
  # If the year is not formed as a four digit string or number, then
  # will throw an error.
  # Example query: { year: 2013 }
  @url: (query) ->
    year  = query.year
    if not year? or !/^\d\d\d\d$/.test year.toString()
      throw Error 'Missing query parameters'
    try year = parseInt year, 10
    catch err then throw Error "Badly formed year value [#{year}]"
    period = "#{"#{year}".slice(-2)}-#{"#{year + 1}".slice(-2)}"
    "#{@EXAM_DOMAIN}/pastpapers/papers.#{period}"

