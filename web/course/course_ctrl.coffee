classy = angular.module 'classy'

classy.controller 'CourseCtrl', ['$scope', '$stateParams', '$window', 'CourseResource',\
                                ($scope, $stateParams, $window, CourseResource) ->

  CourseResource.getCourse().get({id: $stateParams.mid}).$promise.then (data) ->
    $scope.course = data

  $scope.discussions = CourseResource.getDiscussions()
  $scope.dateString = utils.dateString
  $scope.getIcon = utils.getIcon

  $scope.gotoResource = (link) ->
    console.log link
    $window.open link, '_blank'

  $scope.showGivens = (id) ->
    console.log "Showing #{id}"

]

classy.factory 'CourseResource', ['$resource', ($resource) ->
  
  class CourseProvider
    @getCourse: ->
      $resource 'api/courses/2013/:id', {id: '@id'} , {'get': {method: 'GET'}}

    # Temporary method
    @getDiscussions: ->
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
]


utils =

  # Returns a string representing given n, with pushed '0' if n<10
  toTwoDigits: (n) ->
    if n < 10 then return "0#{n}" else return n

  # Returns a string representation of the date of the given timestamp
  dateString: (timestamp) ->
    date = new Date((parseInt timestamp) * 1000)
    return [
             utils.toTwoDigits date.getDate()
             utils.toTwoDigits date.getMonth()+1
             date.getFullYear()
           ].join("/")

  # Returns a fontawesome class name for icon based on given exercise type
  getIcon: (type) ->
    switch type
      when "pdf" then return "fa-file-pdf-o"
      when "url" then return "fa-external-link"
      when "ESSAY" then return "fa-align-left"
      when "TUT" then return "fa-institution"
      when "CW" then return "fa-folder-o"
      when "LAB" then return "fa-code"
      else return "fa-pencil-square-o"

