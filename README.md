![resume](https://socialify.git.ci/anishshobithps/resume/image?description=1&font=Inter&forks=1&issues=1&language=1&name=1&owner=1&pattern=Solid&pulls=1&stargazers=1&theme=Auto)

Welcome to my resume repository! This repository contains my resume written in TeX, allowing for easy customization and a professional look.

## Prerequisites

- [Docker](https://docs.docker.com/)
- [Git](https://git-scm.com/)

## Contents

- [`main.tex`](./main.tex): The main `TeX` file for my resume.
- [`formatting.sty`](./formatting.sty): A custom style file for formatting the resume.
- [`sections/`](./sections/): Individual `TeX` files for each section of the resume.
- [`schema.json`](./schema.json): Schema.org JSON-LD structured data embedded in the PDF.
- [`resume.json`](./resume.json): JSON Resume open standard, embedded in the PDF for ATS parsers.

> [!NOTE]
> This repository uses a custom Docker image for compiling the resume, ensuring consistency and reproducibility across different environments.

## How to Use

<p>1. <strong>Clone the repository</strong>:</p>

```sh
git clone git@github.com:anishshobithps/resume.git
```

Or via HTTPS:

```sh
git clone https://github.com/anishshobithps/resume.git
```

<p>2. <strong>Build the Docker image</strong>:</p>

```sh
docker build -t latex-builder .docker
```

<p>3. <strong>Compile the resume</strong>:</p>

```sh
docker run --rm -v "$(pwd):/data" latex-builder -jobname="Anish_Shobith_P_S_Resume" main.tex
```

> [!NOTE]
> `jobname` controls the output filename — change it as you wish.

## Metadata

The compiled PDF contains rich embedded metadata across multiple standards, readable by ATS systems, semantic crawlers, and document parsers:

| Standard           | Description                                                      |
| ------------------ | ---------------------------------------------------------------- |
| XMP / Dublin Core  | Title, author, keywords, rights, language, dates                 |
| IPTC Core          | Contact email, URL, address                                      |
| Schema.org JSON-LD | Person, occupation, education, projects, skills with ATS aliases |
| JSON Resume        | Open standard parsed natively by Workday, Greenhouse, and Lever  |

Verify the metadata after compiling:

```sh
exiftool -xmp:all Anish_Shobith_P_S_Resume.pdf
```

Extract embedded attachments:

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

- **Content**: Update [`main.tex`](./main.tex) and the files in [`sections/`](./sections/).
- **Formatting**: Modify [`formatting.sty`](./formatting.sty) to change the appearance.
- **Structured data**: Update [`schema.json`](./schema.json) and [`resume.json`](./resume.json) to reflect your own information.

## Releases

> [!IMPORTANT]
> GitHub Actions automatically builds and releases the resume on every push to `main`.

Download the latest compiled PDF from the [Releases](https://github.com/anishshobithps/resume/releases/latest) page.

## License

This project is licensed under the Apache-2.0 License. See the [`LICENSE`](https://github.com/anishshobithps/resume?tab=Apache-2.0-1-ov-file) file for details.
