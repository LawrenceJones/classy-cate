bookingSeeds = require 'test/seeds/bookings'
Booking = (require 'app/models').Booking

bookingJson = ->
  (new Booking.model(bookingSeeds.dogWalking())).api()

module.exports = BookingModel =

  name: 'Booking'
  labels:
    booker: 'user who is making/has made the booking'
    solver: 'user who is being booked/has been booked'
    requested: 'time that booker requested booking'
    accepted: 'time at which the solver accepted this booking'
    confirmed: 'time that both booker and solver confirmed details'
    cancelled: 'time that the booking was cancelled'
    start: 'booking start time'
    end: 'booking end time'
    task: 'booking task title'
    hourly: 'hourly rate charged by the solver'
    expenses: 'any extra charges to be paid to solver'
    location: 'location of the booking'
    summary: 'description of the booking'
    # Post labels
    posts:
      ptype: 'post type, comment|location|time|hourly|cancellation'
      author: 'user that submitted post'
      value: 'post value, structure depends on ptype'
      posted: 'time at which the post was submitted'
      accepted: 'time that change was accepted, defaults to posted for comment'
    

  # Standard api 1A response
  get:
    res: bookingJson

  update:
    req: ->
      task: 'New Task Name'
    res: ->
      json = bookingJson()
      json.task = 'New Task Name'
      json

  all:
    res: -> [bookingJson()]


