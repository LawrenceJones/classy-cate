classy = angular.module 'classy'

classy.factory 'Timetable', (Resource) ->
  class Timetable extends Resource({
    actions:
      get: '/api/timetable/:year/:period'
    defaultParams: year: 2013, period: 3
  })


classy.controller 'TimetableCtrl', ($scope, $stateParams, Timetable) ->
  dayMS = 24*60*60*1000
  colspan = (ex) -> (ex.end - ex.start)/dayMS + 1
  contains = (ex, timestamp) -> ex.start <= timestamp <= ex.end

  # Returns the timestamp of midnight on the day of the given timestamp
  midnightTimestamp = (timestamp) ->
    dayMS * Math.floor (timestamp / dayMS)

  # Given the returned json the function returns a data structure of the form
  # [{name: string, rows: [{colspan: number, ex: object/null}]}]
  formatExercises = (timetable) ->
    timetable.modules.map (course) ->
      courseTable =
        name: course.name
        rows: (splitInRows course.exercises).map (row) ->
          formattedRow = []
          i = 0
          console.log timetable.start
          # For each day, insert an exercise (if present) or an
          # empty cell with colspan 1
          for t in [timetable.start..timetable.end] by dayMS
            i++ while row[i]?.end < t
            if (midnightTimestamp t) is (midnightTimestamp row[i]?.start)
              formattedRow.push {colspan: colspan(row[i]), ex: row[i]}
            else if (not row[i]?) or not contains(row[i], t)
              formattedRow.push {colspan: 1, ex: null}
          return formattedRow

  splitInRows = (exercises) ->
    # Returns true if the given exercise overlaps with the last
    # exercise in the given row
    overlaps = (exercise, row) ->
      row.length > 0 and \
      (midnightTimestamp row[row.length-1].end) + dayMS >= exercise.start

    exercises = exercises.sort (e1, e2) -> e1.start - e2.start

    # Initialise with one subrow
    rows = [ [] ]
    subrow = 0
    
    for exercise in exercises
      while overlaps exercise, rows[subrow]
        rows.push [] if ++subrow is rows.length
      rows[subrow].push exercise
      subrow = 0
    rows
   
  (t = Timetable.get({})).$promise
  .then (course) ->
    $scope.days = (new Date(d).getDate() for d in [t.start..t.end] by dayMS)
    $scope.courses = formatExercises t

  .catch (err) ->
    console.log err

