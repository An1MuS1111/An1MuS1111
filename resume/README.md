# Abdullah Al Khalid — Typst CV

Converted from the Word CV using a customized [imprecv](https://github.com/jskherman/imprecv) template. Layout follows the upstream project:

```
.
├── cv.typ                 # template engine (customized)
├── utils.typ              # date and helper functions (customized)
├── cv.typ.schema.json     # YAML schema
├── typst.toml
├── makefile
├── LICENSE
└── template/
    ├── template.typ       # content file: styles + section order
    └── template.yml       # all CV data
```

## Usage

```bash
make compile
# or
typst compile --root . template/template.typ Abdullah_Al_Khalid_CV.pdf

make watch
```

Requires Typst 0.11+ and the IBM Plex Serif / IBM Plex Mono fonts.

Edit `template/template.yml` for content. Edit `template/template.typ` for section order and page style.

## Template customizations

The upstream package expects ISO dates and quote-only references. This copy keeps the imprecv file layout and adds:

- Dates accept `YYYY`, `YYYY-MM`, `YYYY-MM-DD`, `present`, or omitted fields
- Projects support an optional `stack` label and optional dates
- References support title, organization, address, phone, and email
- Extra `summary` and `courses` sections
- Contact line uses readable LinkedIn / GitHub slugs
- A4 page, IBM Plex Serif, tighter professional spacing
