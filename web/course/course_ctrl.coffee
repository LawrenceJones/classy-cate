classy = angular.module 'classy'

classy.controller 'CourseCtrl', ['$scope', '$stateParams', '$window', 'CourseResource',\ 
                                ($scope, $stateParams, $window, CourseResource) ->
  
  $scope.course = CourseResource.getCourse $stateParams.mid
  $scope.discussions = $scope.course.getDiscussions()

  # Returns a fontawesome class name for icon based on given exercise type
  $scope.noteIcon = (type) ->
    switch type
      when "pdf" then return "fa-file-pdf-o"
      when "url" then return "fa-external-link"
      else return "fa-pencil-square-o"

  $scope.exerciseIcon = (type) ->
    switch type
      when "ESSAY" then return "fa-align-left"
      when "TUT" then return "fa-institution"
      when "CW" then return "fa-folder-o"
      when "LAB" then return "fa-code"

  # Returns a string representation of the date of the given timestamp
  $scope.dateString = (timestamp) ->
    date = new Date((parseInt timestamp) * 1000)
    return [ toTwoDigits date.getDate()
             toTwoDigits date.getMonth()+1
             date.getFullYear()
    ].join("/")

  #
  $scope.gotoResource = (link) ->
    console.log link
    $window.open link, '_blank'

  # 
  $scope.showGivens = (id) ->
    console.log "Showing #{id}"

  # Returns a string representing given n, with pushed '0' if n<10
  toTwoDigits = (n) ->
    if n < 10 then return "0#{n}" else return n
]

classy.factory 'CourseResource', ->
  
  class CourseProvider
    @getCourse: (mid) ->

      {
        mid: "220"
        name: "Software Engineering - Algorithms"
        discussions: [
          12345
          23456
          34567
          45678
          56789
          67890
        ]
        notes: [
          {
            "number": "1"
            "restype": "url"
            "title": "Administration"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1390089600"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "2"
            "restype": "url"
            "title": "Introduction"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1390089600"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "3"
            "restype": "url"
            "title": "Randomised Algorithms"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1390089600"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "4"
            "restype": "doc"
            "title": "String Matching Algorithms"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1390694400"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "5"
            "restype": "url"
            "title": "Radix Searching Algorithms"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1391644800"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "6"
            "restype": "pdf"
            "title": "Divide and Conquer"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1394150400"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "7"
            "restype": "url"
            "title": "Dynamic Programming"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1394150400"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "8"
            "restype": "url"
            "title": "Greedy Algorithms"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1394150400"
            "discussions": [
              12345
              23456
            ]
          }
          {
            "number": "9"
            "restype": "url"
            "title": "Graph Algorithms"
            "link": "https://cate.doc.ic.ac.uk/showfile.cgi?key=2013:3:458:CLASS:NOTES:USER"
            "time": "1395360000"
            "discussions": [
              12345
              23456
            ]
          }
        ]

        exercises: [
          {
            "number": 1
            "type": "ESSAY"
            "name": "Group Formation for CWs"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 2
            "type": "CW"
            "name": "Randomised Algorithms"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 3
            "type": "CW"
            "name": "Divide and Conquer"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 4
            "type": "TUT"
            "name": "Exercise Batch 1"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 5
            "type": "TUT"
            "name": "Exercise Batch 2"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 6
            "type": "TUT"
            "name": "Exercise Batch 3"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 7
            "type": "TUT"
            "name": "Exercise 4 - Divide and Conquer"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 8
            "type": "TUT"
            "name": "Exercise 5 - Dynamic Programming"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 9
            "type": "TUT"
            "name": "Exercise 6 - Greedy Algorithms"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
          {
            "number": 10
            "type": "TUT"
            "name": "Exercise 7 - Graph Algorithms"
            "start": 1394150400
            "end": 1394150400
            "mailto": "mailto:foo@foo.com"
            "spec": "https://cate.doc.ic.ac.uk"
            "givens": []
            "discussions": [
              12345
              23456
              34567
            ]
          }
        ]

        grades: [
          {
            "number": "1"
            "type": "ESSAY"
            "title": "Group Formation for CWs"
            "setBy": "alw"
            "declaration": 1394150400
            "extension": 1394150400
            "submitted": 1394150400
            "grade": ""
          }
          {
            "number": "2"
            "type": "CW"
            "title": "Randomised Algorithms"
            "setBy": "alw"
            "declaration": 1394150400
            "extension": 1394150400
            "submitted": 1394150400
            "grade": "A*"
          }
          {
            "number": "3"
            "type": "CW"
            "title": "Divide and Conquer"
            "setBy": "bglocker"
            "declaration": 1394150400
            "extension": 1394150400
            "submitted": 1394150400
            "grade": "A*"
          }
        ]

        getDiscussions: ->
          [
            {
              title: "Is lecture this cancelled week?"
              time: 1394150400
              author: "Robert Zhou"
              posts: 0
            }
            {
              title: "I hate this course."
              time: 1394150400
              author: "Ben Anunk"
              posts: 2
            }
            {
              title: "Magic 50 liner to ruin your system."
              time: 1394150400
              author: "Winston Li"
              posts: 1
            }
          ]

      }
