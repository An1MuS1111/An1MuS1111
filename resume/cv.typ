#import "utils.typ"

// set rules
#let setrules(uservars, doc) = {
    set text(
        font: uservars.bodyfont,
        size: uservars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: uservars.linespacing,
    )

    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}

// show rules
#let showrules(uservars, doc) = {
    show heading.where(level: 2): it => block(width: 100%)[
        #v(uservars.sectionspacing)
        #set align(left)
        #set text(font: uservars.headingfont, size: 1em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default: false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(-0.75em) #line(length: 100%, stroke: 1pt + black)
    ]

    show heading.where(level: 1): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.55em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default: false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(2pt)
    ]

    doc
}

#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)
    doc
}

#let jobtitletext(info, uservars) = {
    if ("titles" in info.personal and info.personal.titles != none) and uservars.showTitle {
        block(width: 100%)[
            *#info.personal.titles.join("  /  ")*
            #v(-4pt)
        ]
    } else { none }
}

#let addresstext(info, uservars) = {
    if ("location" in info.personal and info.personal.location != none) and uservars.showAddress {
        let address = info.personal.location.pairs().filter(it => it.at(1) != none and str(it.at(1)) != "")
        let location = address.map(it => str(it.at(1))).join(", ")
        block(width: 100%)[
            #location
            #v(-4pt)
        ]
    } else { none }
}

#let display-url(url) = {
    let cleaned = url.replace("https://", "").replace("http://", "").replace("www.", "")
    if cleaned.ends-with("/") { cleaned = cleaned.slice(0, -1) }
    cleaned
}

#let contacttext(info, uservars) = block(width: 100%)[
    #let primary = (
        if "email" in info.personal and info.personal.email != none { box(link("mailto:" + info.personal.email)[#info.personal.email]) },
        if ("phone" in info.personal and info.personal.phone != none) and uservars.showNumber { box(link("tel:" + info.personal.phone)[#info.personal.phone]) } else { none },
        if ("url" in info.personal) and (info.personal.url != none) {
            box(link(info.personal.url)[#display-url(info.personal.url)])
        }
    ).filter(it => it != none)

    #let social = ()
    #if ("profiles" in info.personal) and (info.personal.profiles.len() > 0) {
        for profile in info.personal.profiles {
            let label = if "username" in profile and profile.username != none and str(profile.username) != "" {
                if lower(profile.network) == "github" { "github.com/" + profile.username }
                else if lower(profile.network) == "linkedin" { "linkedin.com/in/" + profile.username }
                else { display-url(profile.url) }
            } else {
                display-url(profile.url)
            }
            social.push(box(link(profile.url)[#label]))
        }
    }

    #set text(font: uservars.bodyfont, weight: "medium", size: uservars.fontsize)
    #let sep = [#sym.space.en #sym.diamond.filled #sym.space.en]
    #if primary.len() > 0 [ #primary.join(sep) ]
    #if social.len() > 0 [
        #if primary.len() > 0 [ \ ]
        #social.join(sep)
    ]
]

#let cvheading(info, uservars) = {
    align(center)[
        = #info.personal.name
        #jobtitletext(info, uservars)
        #addresstext(info, uservars)
        #contacttext(info, uservars)
    ]
}

#let cvsummary(info, title: "Summary", isbreakable: true) = {
    if ("summary" in info) and (info.summary != none) {
        block(breakable: isbreakable)[
            == #title
            #eval(info.summary, mode: "markup")
        ]
    }
}

#let cvwork(info, title: "Work Experience", isbreakable: true) = {
    if ("work" in info) and (info.work != none) { block[
        == #title
        #for w in info.work {
            block(width: 100%, breakable: isbreakable)[
                #if ("url" in w) and (w.url != none) [
                    *#link(w.url)[#w.organization]* #h(1fr) *#w.location* \
                ] else [
                    *#w.organization* #h(1fr) *#w.location* \
                ]
            ]
            let index = 0
            for p in w.positions {
                if index != 0 { v(0.6em) }
                block(width: 100%, breakable: isbreakable, above: 0.6em)[
                    #let start = utils.opt-date(p, "startDate")
                    #let end = utils.opt-date(p, "endDate")
                    #text(style: "italic")[#p.position] #h(1fr)
                    #utils.daterange(start, end) \
                    #if ("highlights" in p) and (p.highlights != none) {
                        for hi in p.highlights [
                            - #eval(hi, mode: "markup")
                        ]
                    }
                ]
                index = index + 1
            }
        }
    ]}
}

#let cveducation(info, title: "Education", isbreakable: true) = {
    if ("education" in info) and (info.education != none) { block[
        == #title
        #for edu in info.education {
            let start = utils.opt-date(edu, "startDate")
            let end = utils.opt-date(edu, "endDate")

            let edu-items = ""
            if ("honors" in edu) and (edu.honors != none) {
                edu-items = edu-items + "- *Honors*: " + edu.honors.join(", ") + "\n"
            }
            if ("courses" in edu) and (edu.courses != none) {
                edu-items = edu-items + "- *Courses*: " + edu.courses.join(", ") + "\n"
            }
            if ("highlights" in edu) and (edu.highlights != none) {
                for hi in edu.highlights {
                    edu-items = edu-items + "- " + hi + "\n"
                }
                edu-items = edu-items.trim("\n")
            }

            block(width: 100%, breakable: isbreakable)[
                #if ("url" in edu) and (edu.url != none) [
                    *#link(edu.url)[#edu.institution]* #h(1fr) *#edu.location* \
                ] else [
                    *#edu.institution* #h(1fr) *#edu.location* \
                ]
                #if ("area" in edu) and (edu.area != none) [
                    #text(style: "italic")[#edu.studyType in #edu.area] #h(1fr)
                ] else [
                    #text(style: "italic")[#edu.studyType] #h(1fr)
                ]
                #utils.daterange(start, end) \
                #if edu-items != "" { eval(edu-items, mode: "markup") }
            ]
        }
    ]}
}

#let cvaffiliations(info, title: "Leadership and Activities", isbreakable: true) = {
    if ("affiliations" in info) and (info.affiliations != none) { block[
        == #title
        #for org in info.affiliations {
            let start = utils.opt-date(org, "startDate")
            let end = utils.opt-date(org, "endDate")

            block(width: 100%, breakable: isbreakable)[
                #if ("url" in org) and (org.url != none) [
                    *#link(org.url)[#org.organization]* #h(1fr) *#org.at("location", default: "")* \
                ] else [
                    *#org.organization* #h(1fr) *#org.at("location", default: "")* \
                ]
                #if "position" in org and org.position != none [
                    #text(style: "italic")[#org.position] #h(1fr)
                    #utils.daterange(start, end) \
                ] else if start != none or end != none [
                    #h(1fr) #utils.daterange(start, end) \
                ]
                #if ("highlights" in org) and (org.highlights != none) {
                    for hi in org.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]}
}

#let cvprojects(info, title: "Projects", isbreakable: true) = {
    if ("projects" in info) and (info.projects != none) { block[
        == #title
        #for project in info.projects {
            let start = utils.opt-date(project, "startDate")
            let end = utils.opt-date(project, "endDate")
            block(width: 100%, breakable: isbreakable)[
                #if ("url" in project) and (project.url != none) [
                    *#link(project.url)[#project.name]*
                ] else [
                    *#project.name*
                ]
                #if "stack" in project and project.stack != none [
                    #h(0.4em) #text(size: 0.9em, fill: rgb("#333333"))[(#project.stack)]
                ]
                \
                #let affil = if "affiliation" in project { project.affiliation } else { none }
                #if affil != none [
                    #text(style: "italic")[#affil] #h(1fr) #utils.daterange(start, end) \
                ] else if start != none or end != none [
                    #h(1fr) #utils.daterange(start, end) \
                ]
                #if ("highlights" in project) and (project.highlights != none) {
                    for hi in project.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]}
}

#let cvawards(info, title: "Honors and Awards", isbreakable: true) = {
    if ("awards" in info) and (info.awards != none) { block[
        == #title
        #for award in info.awards {
            let date = utils.opt-date(award, "date")
            block(width: 100%, breakable: isbreakable)[
                #if ("url" in award) and (award.url != none) [
                    *#link(award.url)[#award.title]* #h(1fr) *#award.at("location", default: "")* \
                ] else [
                    *#award.title* #h(1fr) *#award.at("location", default: "")* \
                ]
                Issued by #text(style: "italic")[#award.issuer] #h(1fr) #date \
                #if ("highlights" in award) and (award.highlights != none) {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]}
}

#let cvcertificates(info, title: "Licenses and Certifications", isbreakable: true) = {
    if ("certificates" in info) and (info.certificates != none) { block[
        == #title
        #for cert in info.certificates {
            let date = utils.opt-date(cert, "date")
            block(width: 100%, breakable: isbreakable)[
                #if ("url" in cert) and (cert.url != none) [
                    *#link(cert.url)[#cert.name]* #h(1fr)
                ] else [
                    *#cert.name* #h(1fr)
                ]
                #if "id" in cert and cert.id != none and str(cert.id).len() > 0 [
                    ID: #raw(str(cert.id))
                ]
                \
                Issued by #text(style: "italic")[#cert.issuer] #h(1fr) #date \
            ]
        }
    ]}
}

#let cvcourses(info, title: "Courses", isbreakable: true) = {
    if ("courses" in info) and (info.courses != none) { block(breakable: isbreakable)[
        == #title
        #for course in info.courses [
            - *#course.name*#if "instructor" in course and course.instructor != none [ — #course.instructor]#if "issuer" in course and course.issuer != none [ (#course.issuer)]
        ]
    ]}
}

#let cvpublications(info, title: "Research and Publications", isbreakable: true) = {
    if ("publications" in info) and (info.publications != none) { block[
        == #title
        #for pub in info.publications {
            let date = utils.opt-date(pub, "releaseDate")
            block(width: 100%, breakable: isbreakable)[
                #if "url" in pub and pub.url != none [
                    *#link(pub.url)[#pub.name]* \
                ] else [
                    *#pub.name* \
                ]
                #if "publisher" in pub and pub.publisher != none [
                    Published on #text(style: "italic")[#pub.publisher] #h(1fr) #date \
                ] else if date != none [
                    #h(1fr) #date \
                ]
            ]
        }
    ]}
}

#let cvskills(info, title: "Skills, Languages, Interests", isbreakable: true) = {
    if (("languages" in info) or ("skills" in info) or ("interests" in info)) and ((info.at("languages", default: none) != none) or (info.at("skills", default: none) != none) or (info.at("interests", default: none) != none)) { block(breakable: isbreakable)[
        == #title
        #if ("languages" in info) and (info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Spoken languages*: #langs.join(", ")
        ]
        #if ("skills" in info) and (info.skills != none) [
            #for group in info.skills [
                - *#group.category*: #group.skills.join(", ")
            ]
        ]
        #if ("interests" in info) and (info.interests != none) [
            - *Interests*: #info.interests.join(", ")
        ]
    ]}
}

#let ref-card(ref) = {
    let phone = if "phone" in ref and ref.phone != none { link("tel:" + str(ref.phone))[#ref.phone] } else { none }
    let email = if "email" in ref and ref.email != none { link("mailto:" + ref.email)[#ref.email] } else { none }
    let bits = (phone, email).filter(it => it != none)

    block(width: 100%)[
        #if ("url" in ref) and (ref.url != none) [
            *#link(ref.url)[#ref.name]* \
        ] else [
            *#ref.name* \
        ]
        #if "title" in ref and ref.title != none [
            #text(style: "italic")[#ref.title] \
        ]
        #if "organization" in ref and ref.organization != none [
            #ref.organization \
        ]
        #if "address" in ref and ref.address != none [
            #text(size: 0.92em)[#ref.address] \
        ]
        #if bits.len() > 0 [
            #bits.join([ · ]) \
        ]
        #if "reference" in ref and ref.reference != none and str(ref.reference).trim() != "" [
            "#ref.reference"
        ]
    ]
}

#let cvreferences(info, title: "References", isbreakable: true) = {
    if ("references" in info) and (info.references != none) { block[
        == #title
        #if info.references.len() == 2 {
            grid(
                columns: (1fr, 1fr),
                column-gutter: 1.2em,
                row-gutter: 0.6em,
                ref-card(info.references.at(0)),
                ref-card(info.references.at(1)),
            )
        } else {
            for ref in info.references {
                block(width: 100%, breakable: isbreakable, below: 0.6em, ref-card(ref))
            }
        }
    ]}
}

#let endnote(uservars) = {
    if uservars.sendnote {
        place(
            bottom + right,
            dx: 9em,
            dy: -7em,
            rotate(-90deg, block[
                #set text(size: 4pt, font: "IBM Plex Mono", fill: silver)
                \*This document was last updated on #datetime.today().display("[year]-[month]-[day]") using #strike(stroke: 1pt)[LaTeX] #underline(link("https://typst.app/home")[*Typst*]). \
            ])
        )
    } else {
        place(
            bottom + right,
            block[
                #set text(size: 5pt, font: "IBM Plex Mono", fill: silver)
                \*This document was last updated on #datetime.today().display("[year]-[month]-[day]") using #strike(stroke: 1pt)[LaTeX] #underline(link("https://typst.app/home")[*Typst*]). \
            ]
        )
    }
}
