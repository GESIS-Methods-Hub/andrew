# Contributing Guide

## Getting Started

```bash
git clone git@github.com:GESIS-Methods-Hub/andrew.git
```

## Source Code

The project is structured as a [R package](https://r-pkgs.org/). Check the `R` directory for the R scripts.

## How-to

### Change `*.drawio.png` images

[draw.io](https://www.drawio.com/) is a open source diagramming software. You can use it online at https://app.diagrams.net/ and download from https://get.diagrams.net/ the desktop version. **All** `*.drawio.png` images include a copy of the diagram that draw.io can use to facilitate changes.

### Install dependencies with `micromamba`

Except for Docker and Quarto, all the depenencies cam be installed with `mamba`. For Docker, follow the steps in https://docs.docker.com/engine/install/ and, for Quarto, download the latest release from https://github.com/quarto-dev/quarto-cli/releases.

Install `micromamba` following the [Mamba Documentation](https://mamba.readthedocs.io/en/latest/installation.html#automatic-installation) and run

```bash
micromamba create -y -n andrew -f env.yaml
```

### Run tests

```r
devtools::load_all()
```

```r
devtools::test()
```

### Run package entrypoint

```r
devtools::load_all()
```

```r
andrew::main(source_dir="demo")
```

### Add new third package dependecy

```r
usethis::use_package("new-third-package-name")
```

### Add new R script

```r
usethis::use_r("new-script")
```

### Add new test

```r
usethis::use_test("new-test")
```

### Skip inclusion of file in built R package

```r
usethis::use_build_ignore("file-to-ignore")
```
