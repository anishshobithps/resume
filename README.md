![resume](https://socialify.git.ci/anishshobithps/resume/image?description=1&font=Inter&forks=1&issues=1&language=1&name=1&owner=1&pattern=Solid&pulls=1&stargazers=1&theme=Auto)

My résumé, written in LaTeX and compiled in a reproducible Docker image — a
clean single-page PDF that doubles as a small software project: versioned, built
in CI, and layered with metadata that parsers, crawlers, and screen readers can
read.

## Why

It started with a PDF viewer showing "resume" instead of my name in its title
bar. That small annoyance turned into a question — what _is_ a PDF, what metadata
can it carry, and how much of a résumé can a machine actually understand? The
answer became this repo: a résumé treated like a production system rather than a
Word file.

📝 Full write-up — **[Making my resume machine-readable](https://anishshobithps.com/blog/making-my-resume-machine-readable)**.

## Prerequisites

- [Docker](https://docs.docker.com/) — builds the LaTeX toolchain
- [Git](https://git-scm.com/)

Optional, for verifying the output:

- [`exiftool`](https://exiftool.org/) — inspect embedded XMP metadata
- [`pdftotext`](https://poppler.freedesktop.org/) (poppler) — confirm ATS text extraction
- `python3` + [`pypdf`](https://pypi.org/project/pypdf/) — read embedded attachments

> [!NOTE]
> Compilation runs inside a custom Docker image for consistency and
> reproducibility across environments. The image is amd64-only (pinned in the
> Dockerfile), so pass `--platform=linux/amd64` on Apple Silicon and other
> arm64 hosts.

## How to Use

**1. Clone the repository**

```sh
git clone https://github.com/anishshobithps/resume.git
cd resume
```

**2. Build the Docker image**

```sh
docker build -t latex-builder .docker
```

**3. Compile the resume**

```sh
docker run --rm --platform=linux/amd64 -v "$(pwd):/data" \
  latex-builder -jobname="Anish_Shobith_P_S_Resume" main.tex
```

> [!NOTE]
> `-jobname` controls the output filename — change it as you wish. Run the
> command twice if you add cross-references or metadata that need a second
> pass to settle (the CI compiles twice for this reason).

## ATS & accessibility

The PDF is engineered so automated systems read it as cleanly as a person does.

### Vanity links that ATS still understand

The header displays short vanity URLs (`n10nce.dev/github`, `n10nce.dev/linkedin`)
but tags each one with a PDF `/ActualText` entry through the `\atslink` macro
(backed by the `accsupp` package). Text extractors, copy-paste, screen readers,
and ATS parsers pull out the **canonical** `github.com/…` and `linkedin.com/in/…`
strings — so profile-detection works — while the printed page stays branded and
tidy. The link's `href` still points at the `n10nce.dev` redirect, keeping any
click analytics intact.

Verify it:

```sh
pdftotext Anish_Shobith_P_S_Resume.pdf - | grep -iE 'github|linkedin'
# prints the canonical github.com / linkedin.com URLs, not n10nce.dev
```

### Tagged for accessibility

`formatting.sty` enables Unicode glyph mapping (`glyphtounicode`,
`\pdfgentounicode`) and marks the document as tagged, so extracted text is
accurate and screen-reader friendly rather than a jumble of ligatures.

### Embedded structured data

The compiled PDF carries rich metadata across several standards, readable by ATS
platforms, semantic crawlers, and document parsers:

| Standard           | Source                     | Description                                                      |
| ------------------ | -------------------------- | ---------------------------------------------------------------- |
| XMP / Dublin Core  | `\hypersetup` in `main.tex`| Title, author, keywords, rights, language, dates                 |
| IPTC Core          | `\hypersetup` in `main.tex`| Contact email, URL, address                                      |
| Schema.org JSON-LD | `schema.json` (embedded)   | Person, occupation, education, projects, skills with ATS aliases |
| JSON Resume        | `resume.json` (embedded)   | Open standard parsed by ATS such as Workday, Greenhouse, Lever   |

> [!NOTE]
> Two traps the write-up documents (and this repo works around):
> `\hypersetup` must stay in [`main.tex`](./main.tex) — `hyperxmp` emits no XMP
> if it runs from a `.sty` file. And avoid LaTeX commands inside metadata values
> (`\DTMtoday`, `\textendash`, …); they silently corrupt the XMP block instead
> of erroring. Attachments use `embedfile` (spec-compliant name tree), not
> `attachfile2`, whose annotations parsers can't see.

Inspect the XMP metadata:

```sh
exiftool -xmp:all Anish_Shobith_P_S_Resume.pdf
```

Extract the embedded JSON attachments:

```sh
python3 -c "
import pypdf
r = pypdf.PdfReader('Anish_Shobith_P_S_Resume.pdf')
for name, data in r.attachments.items():
    print(f'--- {name} ---')
    print(data[0].decode('utf-8'))
"
```

## Customization

- **Content** — edit the files in [`sections/`](./sections/); adjust PDF metadata in [`main.tex`](./main.tex).
- **Formatting** — change layout, fonts, and macros in [`formatting.sty`](./formatting.sty).
- **Links** — point [`sections/header.tex`](./sections/header.tex) at your own handles; `\atslink{href}{visible}{extracted}` sets the displayed text and the canonical string ATS should read.
- **Structured data** — update [`schema.json`](./schema.json) and [`resume.json`](./resume.json) to reflect your own information.

## Releases

> [!IMPORTANT]
> GitHub Actions rebuilds the image and publishes a new release on every push to
> `main` that touches the sources (and on manual dispatch).

Download the latest compiled PDF from the [Releases](https://github.com/anishshobithps/resume/releases/latest) page.

## License

Licensed under the Apache-2.0 License. See [`LICENSE`](./LICENSE) for details.
