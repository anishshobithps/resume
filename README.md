![resume](https://socialify.git.ci/anishshobithps/resume/image?description=1&font=Inter&forks=1&issues=1&language=1&name=1&owner=1&pattern=Solid&pulls=1&stargazers=1&theme=Auto)

Welcome to my resume repository! This repository contains my resume written in TeX, allowing for easy customization and a professional look.

## Prerequisites

- [Docker](https://docs.docker.com/)
- [Git](https://git-scm.com/)

## Contents

- [`main.tex`](./main.tex): The main `TeX` file for my resume.
- [`formatting.sty`](./formatting.sty): A custom style file for formatting the resume.
- [`sections`](./sections/): A directory containing individual `TeX` files for different sections of my resume (e.g., `experience`, `education`, `skills`).

> [!NOTE]
> This repository uses a custom Docker image for compiling the resume, ensuring consistency and reproducibility across different environments.

## How to Use

<p> 1. <strong>Clone the repository</strong>: Clone this repository to your local machine using the following command: </p>

```sh
git clone git@github.com:anishshobithps/resume.git
```

This command uses SSH to clone the repository. Make sure you have an SSH key set up in your GitHub account. You can find more information about setting up Git in the sources. If you prefer to use HTTPS, you can use the following command:

```sh
git clone https://github.com/anishshobithps/resume.git
```

This command will create a local copy of the repository on your computer, allowing you to access and modify the files. You can then proceed with the other steps to compile and customize your resume.

<p> 2. <strong>Build the docker Image</strong>: Navigate to the repository's root directory and build the Docker image:</p>

```sh
docker build -t latex-builder .docker
```

<p> 3. <strong>Run the Container and Generate the Resume</strong>: Compile the LaTeX file to generate the resume PDF:</p>

```sh
docker run --rm -v "$(pwd):/data" latex-builder -jobname="Anish_Shobith_P_S_Resume" main.tex
```

> [!NOTE]
> `jobname` is the name of the file being outputed change as you wish.

## Customizations

- **Edit the TeX files**: Update the content in the [`main.tex`](./main.tex) and [`section`](./sections/) files to reflect your own information.
- **Adjust formatting**: Modify the [`formatting.sty`](./formatting.sty) file to customize the appearance of your resume.

## Releases

> [!IMPORTANT]
> GitHub Actions are used to automatically build and deploy the resume on every push to the repository, simplifying the update process.

You can download the latest compiled version of my resume from the [Releases](https://github.com/anishshobithps/resume/releases/latest) page.

## License

This project is licensed under the Apache-2.0 License. See the [`LICENSE`](https://github.com/anishshobithps/resume?tab=Apache-2.0-1-ov-file) file for details.
