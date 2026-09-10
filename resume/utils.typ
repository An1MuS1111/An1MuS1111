// Helper Functions — customized to accept year, year-month, ISO dates,
// "present", empty strings, and missing values without breaking compilation.

#let monthname(n, display: "short") = {
    n = int(n)
    let month = ""

    if n == 1 { month = "January" }
    else if n == 2 { month = "February" }
    else if n == 3 { month = "March" }
    else if n == 4 { month = "April" }
    else if n == 5 { month = "May" }
    else if n == 6 { month = "June" }
    else if n == 7 { month = "July" }
    else if n == 8 { month = "August" }
    else if n == 9 { month = "September" }
    else if n == 10 { month = "October" }
    else if n == 11 { month = "November" }
    else if n == 12 { month = "December" }
    else { month = none }

    if month != none {
        if display == "short" {
            month = month.slice(0, 3)
        } else {
            month
        }
    }
    month
}

#let strpdate(isodate) = {
    if isodate == none { return none }
    let raw = str(isodate).trim()
    if raw == "" { return none }

    let lower = lower(raw)
    if lower == "present" or lower == "now" or lower == "current" {
        return "Present"
    }

    // Already a display string such as "Sep 2024"
    if raw.contains(" ") { return raw }

    let parts = raw.split("-")
    if parts.len() == 1 and parts.at(0).len() == 4 {
        return parts.at(0)
    }
    if parts.len() >= 2 {
        let year = int(parts.at(0))
        let month = int(parts.at(1))
        let monthName = monthname(month, display: "short")
        if monthName == none { return parts.at(0) }
        return monthName + " " + str(year)
    }
    return raw
}

#let daterange(start, end) = {
    if start != none and end != none [
        #start #sym.dash.en #end
    ] else if start == none and end != none [
        #end
    ] else if start != none and end == none [
        #start
    ]
}

#let has-text(value) = {
    value != none and str(value).trim() != ""
}

#let opt-date(entry, key) = {
    if key in entry { strpdate(entry.at(key)) } else { none }
}
