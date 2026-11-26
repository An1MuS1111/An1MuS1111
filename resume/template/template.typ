#import "../cv.typ": *

#let cvdata = yaml("template.yml")

#let uservars = (
  // Libertinus Serif ships inside Typst, so the PDF looks the same on every
  // machine. (Your committed PDF already used it: IBM Plex was not installed.)
  headingfont: "Libertinus Serif",
  bodyfont: "Libertinus Serif",
  fontsize: 10pt,
  linespacing: 5pt,
  sectionspacing: 3pt,
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
    margin: (top: 1.0cm, bottom: 1.0cm, left: 1.25cm, right: 1.25cm),
  )
  set list(indent: 0.65em)
  // Tighter gaps between entries and sections so the CV stays on one page.
  set block(spacing: 0.75em)
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
#cvskills(cvdata, title: "Technical Skills & Languages")
#cvwork(cvdata, bullet: true)
#cvprojects(cvdata, title: "Open Source", key: "opensource")
#cvprojects(cvdata, title: "Projects")
#cveducation(cvdata)
#cvaffiliations(cvdata, title: "Achievements")
#cvawards(cvdata)
#cvcertificates(cvdata)
#cvcourses(cvdata)
#cvpublications(cvdata)
// Not rendered for HENNGE (the page is for evidence, not contacts).
// Uncomment to show the references kept in template.yml:
// #cvreferences(cvdata)
// The grey "last updated with Typst" footer. Uncomment to bring it back:
// #endnote(uservars)
