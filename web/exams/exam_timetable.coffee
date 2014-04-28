classy = angular.module 'classy'

# Tube strike times
tubeStrikes = [
  {
    # 28th April 21:00 -> 1st May 11:00
    start: new Date(2014, 3, 28, 21, 0)
    end:   new Date(2014, 4, 1, 11, 0)
  }, {
    # 5th May 21:00 -> 9th May 11:00
    start: new Date(2014, 4, 5, 21, 0)
    end:   new Date(2014, 4, 9, 11, 0)
  }
]

# Calculates if a date is within a tube strike
duringStrikes = (date) ->
  for strike in tubeStrikes
    return true if strike.start < date < strike.end
  return false

classy.factory 'ExamTimetable', (Resource, Exam, $rootScope) ->
  class ExamTimetable extends Resource {
    baseurl: '/api/exam_timetable'
    parser: ->
      Exam.myExams ?= {}
      for exam in @exams
        (Exam.myExams[$rootScope.AppState.currentUser] ?= {})[exam.id] = @
        exam.datetime = new Date exam.datetime
        exam.tminus =
          Math.max 0, Math.round (exam.datetime - Date.now())/(1000*60*60*24)
        exam.strike = duringStrikes exam.datetime
  }

