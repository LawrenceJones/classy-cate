classy = angular.module 'classy'

classy.factory 'PeriodFormatter', (Current) ->
  (start, end) ->
    getMonthName = (monthNumber) ->
      (['January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August', 'September',
        'October', 'November', 'December'])[monthNumber]
    isWeekend = (date) ->
      date.getDay() % 6 is 0

    period = days: [], months: {}
    for d in start.getDatesTo(end)
      period.days.push {
        number: d.getDate()
        isWeekend: isWeekend d
        isToday: Current.isToday d
      }

      month = d.getMonth()
      if period.months[month]?
        period.months[month].size++
      else
        period.months[month] = {name: getMonthName(month), size: 1}
    period


# Given the returned json the factory returns a data structure of the form
# [{name: string, rows: [{ex: object/null, options: object}]}]
classy.factory 'CourseFormatter', (Current) ->
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

  getOptions = (ex, date) ->
    colspan: (ex?.start.getDatesTo(ex.end).length) ? 1
    isToday: Current.isToday date

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
