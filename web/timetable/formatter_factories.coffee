classy = angular.module 'classy'

classy.factory 'PeriodFormatter', ->
  (start, end) ->
    (d.getDate() for d in start.getDatesTo(end))

classy.factory 'CourseFormatter', ->
  dayMS = 24*60*60*1000
  contains = (ex, date) -> ex.start <= date <= ex.end
  splitInRows = (exercises) ->
        # Returns true if the given exercise overlaps with the last
        # exercise in the given row
        overlaps = (exercise, row) ->
          row.length > 0 and \
          (new Date(row[row.length-1].end.getTime() + dayMS).midnight()) >= exercise.start

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

      isToday = (date) ->
        date.midnight().getTime() is (new Date(2014, 1, 15).midnight().getTime())

      getOptions = (ex, date) ->
        colspan: if ex? then (ex.start.getDatesTo(ex.end).length) else 1
        isToday: isToday date


  # Given the returned json the function returns a data structure of the form
  # [{name: string, rows: [{ex: object/null, options: object}]}]
  formatCourses = (timetable) ->
    timetable.modules.map (course) ->
      courseTable =
        name: course.name
        rows: (splitInRows course.exercises).map (row) ->
          formattedRow = []
          i = 0
          # For each day, insert an exercise (if present) or an
          # empty cell with colspan 1
          for date in timetable.start.getDatesTo timetable.end
            i++ while (row[i]?.end.getTime()) < date.getTime()
            if (date.midnight().getTime()) is (row[i]?.start.midnight().getTime())
              formattedRow.push {ex: row[i], options: getOptions row[i], date}
            else if (not row[i]?) or not contains(row[i], date)
              formattedRow.push {ex: null, options: getOptions null, date}
          formattedRow

  return formatCourses
