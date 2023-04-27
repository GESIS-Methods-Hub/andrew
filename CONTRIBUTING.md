# Contributing Guide

## Getting Started

```bash
git clone git@git.gesis.org:methods-hub/portal.git
```

## Source Code

The project is structured as a [R package](https://r-pkgs.org/). Check the `R` directory for the R scripts.

## How to

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
methodshub::main()
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