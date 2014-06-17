studentSeeds =

  lawrence: ->
    validFrom: 1348873200000# {{{
    validTo: 1474930800000
    tid: 14678
    login: 'lmj112'
    email: 'lawrence.jones12@imperial.ac.uk'
    fname: 'Lawrence'
    lname: 'Jones'
    salutation: 'Mr.'
    origin: 'HOME'
    entryYear: 2012
    url: 'http://www.doc.ic.ac.uk/~lmj112'
    cand: '00730706'
    courses:
      [
        cid: '140'
        name: 'Logic'
        eid: 'C146'
        terms: [1]
        classes: ['c1', 'j1']
      ,
        cid: '141'
        name: 'Reasoning about Programs'
        eid: 'C146'
        terms: [2]
        classes: ['c1']
      ,
        cid: '211'
        name: 'Operating Systems'
        eid: 'C214'
        terms: [2]
        classes: ['c2','j2']
      ,
        cid: '261'
        name: 'Laboratory 2'
        eid: 'XC261'
        terms: [1,2]
        classes: ['c2', 'j2']
      ]
    enrolment:
      [
        year: 2012
        class: 'c1'
      ,
        year: 2013
        class: 'c2'
      ]# }}}

  nic: ->
    validTo: null# {{{
    validFrom: 1380322800000
    tid: 15557
    login: 'np1813'
    email: 'nicolas.prettejohn13@imperial.ac.uk'
    fname: 'Nicolas'
    lname: 'Prettejohn'
    salutation: 'Mr.'
    origin: 'HOME'
    entryYear: 2013
    url: 'http://www.doc.ic.ac.uk/~np1813'
    courses:
      [
        cid: '112'
        name: 'Hardware'
        eid: 'C114'
        terms: ['1']
        classes: ['c1']
      ,
        cid: '113'
        name: 'Architecture'
        eid: 'C114'
        terms: [2]
        classes: ['c1', 'j1']
      ]
    enrolment:
      [
        year: 2013
        class: 'c1'
      ]# }}}

if window? then window.students = studentSeeds
else module.exports = studentSeeds
