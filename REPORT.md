# LaTeX Resume Document System

## Table of Contents

1. [Abstract](#1-abstract)
2. [Introduction](#2-introduction)
   - 2.1 [Key Contributions](#21-key-contributions)
3. [Problem Definition](#3-problem-definition)
4. [System Overview](#4-system-overview)
5. [Design Decisions](#5-design-decisions)
6. [Implementation](#6-implementation)
   - 6.1 [Execution Flow](#61-execution-flow)
   - 6.2 [Core Components](#62-core-components)
   - 6.3 [Data Model](#63-data-model)
   - 6.4 [Interfaces](#64-interfaces)
7. [Evaluation](#7-evaluation)
8. [Limitations](#8-limitations)
9. [Future Work](#9-future-work)
10. [Conclusion](#10-conclusion)

---

## 1. Abstract

This repository implements a document generation system for a professional resume. The source is written in LaTeX, compiled through a containerised build environment, and released automatically via GitHub Actions. The compiled PDF carries metadata in three separate standards: XMP/Dublin Core, Schema.org JSON-LD, and the JSON Resume open standard. I built this because a plain PDF is not enough for modern job applications. Recruiting platforms scan documents with automated parsers, and most parsers expect structured data that a Word-exported PDF does not reliably provide. This system addresses that gap by treating the resume as both a human-readable document and a machine-readable data artifact.

---

## 2. Introduction

The project is a single-author resume document system hosted at [github.com/anishshobithps/resume](https://github.com/anishshobithps/resume). It is not a web application, an API, or a library. It is a document pipeline: source files go in, a PDF with embedded structured data comes out.

The system has two visible outputs. First, a typeset PDF that a hiring manager reads. Second, that same PDF carries attached JSON files that an ATS parser ingests. Both outputs are produced in one build step, reproducibly, across any machine that runs Docker.

### 2.1 Key Contributions

- A `formatting.sty` package that centralises all layout rules, making content files free of formatting concerns.
- A containerised build step using a pinned TeX Live image, removing environment-specific compilation failures.
- Automated metadata injection for three structured-data standards within a single PDF artifact.
- A GitHub Actions workflow that tags and releases a new PDF on every push to `main`.

---

## 3. Problem Definition

Two separate audiences consume a resume. A person reads the formatted document. A recruiting system parses it programmatically to populate candidate database fields.

LaTeX handles the human-readable side well. It produces consistent glyph rendering, handles font encoding, and separates content from layout. What it does not handle out of the box is machine-readable metadata.

Modern ATS platforms, including Workday, Greenhouse, and Lever, accept the JSON Resume open standard. Search indexers expect Schema.org annotations. PDF tools look for XMP metadata. No single standard covers all three audiences. I chose to embed all three formats in one file rather than maintain separate documents.

A secondary problem is build reproducibility. LaTeX installations differ across operating systems. A package present on one machine is absent or versioned differently on another. I chose Docker to lock the entire build environment.

A third problem is release friction. Publishing a new PDF manually after every content change is error-prone. I chose continuous delivery via GitHub Actions to automate tagging and uploading.

---

## 4. System Overview

The diagram below shows the full pipeline from source files to release artifact.

```mermaid
flowchart TD
    subgraph Source["Source Files"]
        A[main.tex]
        B[formatting.sty]
        C[sections/*.tex]
        D[schema.json]
        E[resume.json]
    end

    subgraph Docker["Docker Build Environment"]
        F[texlive/texlive:latest base image]
        G[tlmgr installs 15 packages]
        H[pdflatex entrypoint]
    end

    subgraph Pipeline["GitHub Actions Workflow"]
        I[Push to main]
        J[Build and push Docker image to GHCR]
        K[Update metadata dates]
        L[Run pdflatex via Docker]
        M[Generate changelog from git log]
        N[Create GitHub Release]
    end

    subgraph Output["Artifacts"]
        O[Anish_Shobith_P_S_Resume.pdf]
        P[Embedded schema.json attachment]
        Q[Embedded resume.json attachment]
    end

    A --> H
    B --> H
    C --> H
    D --> H
    E --> H
    F --> G --> H
    I --> J --> K --> L --> M --> N
    L --> O
    D --> P
    E --> Q
    O --> P
    O --> Q
```

*Figure 1: End-to-end build pipeline from source to released PDF.*

The pipeline starts when a push lands on `main`. GitHub Actions builds and pushes the Docker image to GHCR, injects the current date into `resume.json` and `schema.json`, runs pdflatex inside the container, and creates a versioned GitHub Release with the compiled PDF attached.

---

## 5. Design Decisions

**LaTeX over word processors.** LaTeX separates content from layout at the language level. The `formatting.sty` file owns all layout logic. The section files contain only content. Changing the font, spacing, or margin requires editing one file, not hunting through a word processor's style panel. The `XCharter` font was chosen for its T1 encoding support and broad glyph coverage, which matters for PDF/UA compliance.

**Docker for build isolation.** I pinned the TeX Live image to the 2025 release channel with an explicit `tlmgr` package list. This means the build on a contributor's laptop produces the same PDF as the one on the CI runner. Without the container, a missing `hyperxmp` package or a mismatched `embedfile` version would silently produce a PDF without metadata.

**Three metadata standards in one file.** XMP/Dublin Core covers document search tools and PDF viewers. Schema.org JSON-LD covers semantic web indexers. JSON Resume covers ATS platforms. All three are embedded in the compiled PDF as file attachments using `embedfile`. I chose this approach because it requires no separate hosting or API. The PDF is self-contained.

**GitHub Actions for continuous delivery.** The workflow uses `softprops/action-gh-release` to tag releases by run number. Each release includes a generated changelog from `git log` and the PDF file size. I chose this over manual releases because the release notes are reproducible and the PDF is always fresh on `main`.

**Section-based file structure.** Each resume section lives in its own file under `sections/`. The `main.tex` file assembles them with `\input`. This makes it straightforward to add, remove, or reorder sections without touching the root document. The `formatting.sty` defines `\experience`, `\project`, and `\education` commands so the section files read as content declarations, not formatting instructions.

---

## 6. Implementation

### 6.1 Execution Flow

The diagram below shows the call sequence from `pdflatex` invocation to the final PDF.

```mermaid
sequenceDiagram
    participant CI as GitHub Actions
    participant Docker as Docker Container
    participant PDFLaTeX as pdflatex
    participant Main as main.tex
    participant Formatting as formatting.sty
    participant Sections as sections/*.tex
    participant Embedder as embedfile package
    participant Output as PDF Output

    CI->>Docker: docker run pdflatex -jobname="..." main.tex
    Docker->>PDFLaTeX: invoke entrypoint
    PDFLaTeX->>Main: parse document root
    Main->>Formatting: \usepackage{formatting}
    Formatting-->>PDFLaTeX: register custom commands + layout
    Main->>Main: \hypersetup{...} sets XMP metadata
    Main->>Sections: \input{sections/header}
    Main->>Sections: \input{sections/skills}
    Main->>Sections: \input{sections/experience}
    Main->>Sections: \input{sections/projects}
    Main->>Sections: \input{sections/education}
    Sections-->>PDFLaTeX: rendered content
    Main->>Embedder: \embedfile{schema.json}
    Main->>Embedder: \embedfile{resume.json}
    Embedder-->>Output: attach JSON files to PDF
    PDFLaTeX-->>Output: write Anish_Shobith_P_S_Resume.pdf
    Output-->>CI: artifact available for release
```

*Figure 2: Sequence of operations during a single pdflatex compilation pass.*

I noticed that pdflatex writes intermediate files (`.aux`, `.log`, `.out`) during the first pass. The `embedfile` package runs at shipout time, so the JSON attachments are written after all content is typeset. The `-jobname` flag controls the output filename without modifying the source.

### 6.2 Core Components

**`main.tex`**

This is the document root. It sets the document class to `article` at 11pt, imports `formatting.sty`, configures `hypersetup` with all XMP metadata fields (title, author, keywords, copyright, contact, language), and sequences the section inputs. It also calls `\embedfile` twice for the two JSON attachments.

The `\hypersetup` block includes fields from the `hyperxmp` extension: `pdfcontactemail`, `pdfcontacturl`, `pdfcontactaddress`, `pdfcopyright`, and `pdflicenseurl`. These populate IPTC Core fields in the compiled PDF.

**`formatting.sty`**

This file defines all layout behaviour. Key choices:

- `\geometry{a4paper, margin=0.5in}` sets tight margins to fit content on one page.
- `\pagestyle{empty}` removes headers and footers.
- `\pdfgentounicode=1` with `\input{glyphtounicode}` ensures text copy-paste produces readable Unicode, a requirement for PDF/UA.
- `\pdfobjcompresslevel=0` with `\pdfminorversion=7` targets PDF 1.7, which is the minimum version for proper XMP embedding.

Three domain-specific commands are defined: `\experience{role}{org}{location}{date}{items}`, `\project{name}{url}{tech}{items}`, and `\education{degree}{institution}{url}{date}`. Each command handles its own internal spacing via `\vspace{-9pt}` before the itemize block, keeping line density consistent without requiring manual spacing in section files.

**`sections/`**

Six files: `header.tex`, `skills.tex`, `experience.tex`, `projects.tex`, `education.tex`, and `summary.tex`. The `summary.tex` file contains only a `% TODO` comment. The other five are populated. The `header.tex` uses `\Huge`, `\large`, and `\normalsize` for the name and contact line, relying on `\begin{center}` for centering.

**`.docker/Dockerfile`**

Built from `texlive/texlive:latest`. The `RUN` layer pins the repository to the 2025 TeX Live historic mirror and installs exactly 15 packages. No extra tools are installed. The entrypoint is `pdflatex`, so the container accepts pdflatex arguments directly.

**`.github/workflows/build.yml`**

The workflow triggers on pushes to `main` that touch `.tex`, `.cls`, `.sty`, or `.json` files, and on `workflow_dispatch`. It uses four actions: `actions/checkout@v4`, `docker/setup-buildx-action@v3`, `docker/login-action@v3`, and `docker/build-push-action@v5`. The Docker image is cached via GitHub Actions cache (`type=gha`). After building, a `sed` command updates the `lastModified` and `dateModified` fields in `resume.json` and `schema.json` before pdflatex runs.

**`schema.json`**

A Schema.org JSON-LD document containing a `@graph` with two nodes: a `Person` entity and a `CreativeWork` entity. The `Person` node lists occupation history, known technologies, and profile URLs. The `CreativeWork` node lists the document's sections as `ItemList` entries with `alternateName` arrays. The alternate names exist to improve recall in semantic search, since "experience" and "employment history" are treated as equivalent by indexers that support Schema.org.

**`resume.json`**

Follows the JSON Resume open standard (`jsonresume/resume-schema` v1.0.0). It includes `basics`, `work`, `education`, `skills`, and `projects` sections. The `meta` section carries a `version` and `lastModified` field, which the CI workflow updates to the build date before compilation.

### 6.3 Data Model

No database is present. The structured data lives in two JSON files.

The JSON Resume schema (`resume.json`) defines its own type constraints. The `$schema` field points to `https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json`. Each `work` entry requires `name`, `position`, and `startDate`. Each `skills` entry requires `name` and `keywords` array.

The Schema.org document (`schema.json`) uses the `@context` / `@graph` pattern. The two top-level nodes are linked by the `about` property: the `CreativeWork` node references the `Person` node by its `@id`. This lets a semantic indexer traverse the graph and understand that the document describes the person.

Below is the relationship between the two structured data files and the PDF artifact:

```mermaid
erDiagram
    PDF_ARTIFACT {
        string filename "Anish_Shobith_P_S_Resume.pdf"
        string xmp_metadata "embedded via hyperxmp"
        string iptc_metadata "embedded via hyperxmp"
    }
    SCHEMA_JSON {
        string context "https://schema.org"
        string type_person "Person"
        string type_work "CreativeWork"
        string id "https://anishshobithps.com"
    }
    RESUME_JSON {
        string schema "jsonresume v1.0.0"
        object basics
        array work
        array education
        array skills
        array projects
        object meta
    }
    PDF_ARTIFACT ||--|| SCHEMA_JSON : "embedfile attachment"
    PDF_ARTIFACT ||--|| RESUME_JSON : "embedfile attachment"
```

*Figure 3: Relationship between the PDF artifact and its embedded structured data files.*

### 6.4 Interfaces

**Build interface (Docker CLI):**

```sh
docker run --rm -v "$(pwd):/data" latex-builder -jobname="Anish_Shobith_P_S_Resume" main.tex
```

The container mounts the current directory at `/data`, which is the working directory. The `-jobname` flag names the output file. All source files in the current directory are available to pdflatex.

**Metadata inspection (exiftool):**

```sh
exiftool -xmp:all Anish_Shobith_P_S_Resume.pdf
```

This reads the XMP block embedded in the PDF and prints all fields. I use this to verify that the `hyperxmp` fields are written correctly after compilation.

**Attachment extraction (pypdf):**

```python
import pypdf
r = pypdf.PdfReader('Anish_Shobith_P_S_Resume.pdf')
for name, data in r.attachments.items():
    print(f'--- {name} ---')
    print(data[0].decode('utf-8'))
```

This reads the embedded file attachments and prints their contents. It confirms that `schema.json` and `resume.json` are present and intact in the PDF.

---

## 7. Evaluation

The system produces one output file from a deterministic build. The same source files, run through the same Docker image, produce byte-identical PDFs on every build (excluding the metadata date fields, which are intentionally updated by the workflow).

The JSON Resume format is parsed natively by Workday, Greenhouse, and Lever according to the JSON Resume specification. I embedded it as a PDF attachment rather than hosting it at a URL, so no external infrastructure is needed for ATS parsers that support the standard.

The `pdfgentounicode` setting is observable: copying text from the compiled PDF and pasting it into a text editor produces correctly encoded Unicode characters. Without it, ligatures like "fi" copy as a single unreadable glyph.

The GitHub Actions workflow produces a new release on every qualifying push. The release name includes the build number and date. The changelog is generated from `git log --oneline --no-merges` between the previous tag and the current commit, giving each release a traceable history.

The PDF size is reported in the release body via `du -sh`. This is a lightweight check to catch accidental bloat from large embedded assets.

Data not present in repository: benchmark metrics for ATS parsing accuracy, comparative data on metadata field coverage across recruiting platforms.

---

## 8. Limitations

**Single-pass compilation.** The build runs `pdflatex` once. Certain LaTeX features require multiple passes (cross-references, table of contents). This resume does not use those features, so a single pass is sufficient. If sections were added that require cross-references, the build step would need adjustment.

**No validation step for JSON files.** The CI workflow updates `lastModified` and `dateModified` with `sed` substitution. There is no JSON schema validation step before pdflatex runs. A malformed `resume.json` would be embedded silently without error.

**`summary.tex` is not implemented.** The file exists in `sections/` and is referenced nowhere in `main.tex`. It contains only a `% TODO` comment. This section is absent from the compiled PDF.

**Docker image size.** The base image is `texlive/texlive:latest`, which includes the full TeX Live distribution. The `RUN` layer adds 15 specific packages on top of what is already present. The resulting image is several gigabytes. For a build that only needs pdflatex and a handful of packages, this is disproportionately large. A minimal TeX Live scheme with only required packages would reduce image size substantially.

**Metadata date format inconsistency.** The CI workflow uses two separate variables: `DATE=$(date +%Y-%m-%d)` for the `sed` substitution in `resume.json`, and `YEAR=$(date +%Y)` for the `sed` substitution in `schema.json`. The result is that `resume.json` `lastModified` is set to a full ISO 8601 date while `schema.json` `dateModified` is set to a year-only value. The Schema.org specification expects ISO 8601 for `dateModified`. The current value is year-only.

---

## 9. Future Work

**`summary.tex` implementation.** The file exists but is empty. Adding a professional summary section and including it in `main.tex` would complete the document structure.

**JSON validation in CI.** Adding a `jq` or `ajv` validation step before the pdflatex run would catch malformed JSON before it is silently embedded. The `resume.json` schema is already referenced by the `$schema` field, so an ajv validation call is straightforward.

**Typst migration.** The `resume.json` skills section lists Typst as a known tool. Typst is a newer document typesetting system with a simpler syntax and faster compilation. A parallel Typst build would be an interesting comparison, though it would require replacing `hyperxmp` and `embedfile` with Typst equivalents.

**Minimal Docker image.** Replacing `texlive/texlive:latest` with a custom minimal TeX Live scheme image would reduce the image from several gigabytes to under 500 MB. The required packages are already enumerated in the Dockerfile `RUN` layer.

**Schema.org `dateModified` fix.** The workflow step that updates `schema.json` sets the field with `YEAR=$(date +%Y)`, which produces a year-only value. Replacing that with `DATE=$(date +%Y-%m-%d)` and updating the `sed` pattern to substitute the full date string would bring the field into conformance with the Schema.org specification. This requires a matching change to the `sed` substitution regex in the workflow, since the current pattern matches `"dateModified": ".*"` and the replacement string would change from a four-digit year to a full date.

---

## 10. Conclusion

I built this system to solve a concrete problem: a single PDF that satisfies both human readers and automated parsers. The solution uses LaTeX for typesetting, Docker for build reproducibility, `embedfile` for attachment embedding, and GitHub Actions for automated release.

The design is intentionally narrow. It does one thing: produce a well-formatted, metadata-rich PDF from plain text sources. There is no server, no database, no UI. The build runs in under a minute. The output is a single file. Open it in a PDF viewer, parse it with an ATS client, or inspect it with exiftool.

Three limitations are worth noting again: the missing `summary.tex` content, the absent JSON validation step, and the year-only `dateModified` in `schema.json`. Each is a small, targeted fix. The core pipeline works as designed.
