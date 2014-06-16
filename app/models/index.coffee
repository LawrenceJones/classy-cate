module.exports = Models =

  # Each exported model contains a few common fields.
  #
  #   model: The actual mongoose model object
  #   formats: Collection of formatting instance methods for API versions
  #   schema The mongoose schema object
  #   <helpers>: Various functions that should be exposed for testing

  Student: require './student_model'
  Course: require './course_model'
