classy = angular.module 'classy'

classy.factory 'Timetable', (Resource) ->
  class Timetable extends Resource({
    actions:
      get: '/api/timetable/:year/:period'
    defaultParams: year: 2013, period: 3
  })

classy.controller 'TimetableCtrl', ($scope, $stateParams, Timetable) ->
  (timetable = Timetable.get({})).$promise
  .then (course) ->
    $scope.days = getRangeDates timetable.start, timetable.end
    $scope.courses = formatExercises timetable

  .catch (err) ->
    console.log err

dayMS = 24*60*60*1000

# Returns an array with the day numbers between two timestamps ranges
getRangeDates = (start, end) ->
  (new Date(t).getDate() for t in [start..end] by dayMS)

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
        # For each day, insert an exercise (if present) or an
        # empty cell with colspan 1
        for t in [timetable.start..timetable.end] by dayMS
          i++ while row[i]?.t_end < t
          if (midnightTimestamp t) is (midnightTimestamp row[i]?.t_start)
            formattedRow.push {colspan: row[i].colspan(), ex: row[i]}
          else if not row[i]?.contains t
            formattedRow.push {colspan: 1, ex: null}
        formattedRow


splitInRows = (exercises) ->
  # Returns true if the given exercise overlaps with the last
  # exercise in the given row
  overlaps = (exercise, row) ->
    row.length > 0 and \
    (midnightTimestamp row[row.length-1].t_end) + dayMS >= exercise.t_start

  exercises = (exercises.map (ex) ->
    new Exercise ex.id, ex.type, ex.name, ex.start, ex.end)
      .sort (e1, e2) -> e1.compareTo e2

  # Initialise with one subrow
  rows = [ [] ]
  subrow = 0
   
  for exercise in exercises
    while overlaps exercise, rows[subrow]
      rows.push [] if ++subrow is rows.length
    rows[subrow].push exercise
    subrow = 0
  rows

class Exercise
  constructor: (@id, @type, @name, @t_start, @t_end) ->

  colspan: ->
    (@t_end - @t_start)/dayMS + 1

  contains: (timestamp) ->
    @t_start <= timestamp <= @t_end

  start: -> new Date @t_start
  end:   -> new Date @t_end

  compareTo: (exercise) ->
    return -1 if @t_start < exercise.t_start
    return  1 if @t_start > exercise.t_start
    return 0
 
