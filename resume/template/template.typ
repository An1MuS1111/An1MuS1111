#import "../cv.typ": *

#let cvdata = yaml("template.yml")

#let uservars = (
  headingfont: "IBM Plex Serif",
  bodyfont: "IBM Plex Serif",
  fontsize: 10pt,
  linespacing: 5.6pt,
  sectionspacing: 4pt,
  showAddress: true,
  showNumber: true,
  showTitle: true,
  headingsmallcaps: false,
  sendnote: false,
)

// setrules and showrules can be overridden by re-declaring them here

#let customrules(doc) = {
  set page(
    paper: "a4",
    numbering: none,
    margin: (top: 1.15cm, bottom: 1.15cm, left: 1.25cm, right: 1.25cm),
  )
  set list(indent: 0.65em)
  doc
}

#let cvinit(doc) = {
  doc = setrules(uservars, doc)
  doc = showrules(uservars, doc)
  doc = customrules(doc)
  doc
}

#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)
#cvsummary(cvdata)
#cvwork(cvdata)
#cveducation(cvdata)
#cvaffiliations(cvdata, title: "Activities & Competitions")
#cvprojects(cvdata, title: "Passion Projects")
#cvawards(cvdata)
#cvcertificates(cvdata)
#cvcourses(cvdata)
#cvpublications(cvdata)
#cvskills(cvdata)
#cvreferences(cvdata)
#endnote(uservars)
