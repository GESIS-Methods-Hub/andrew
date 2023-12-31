# andrew <img src="man/figures/logo.png" align="right" />

`andrew` (Aggregator for Navigatable Discoverable Reproducible and Educational work) is designed to speed up the creation of a **static** website with pages from a collection of tutorials or vignette of **transparent analytic** computational methods. This is inspired by the feed aggregator Planet. Tutorials and vignette **must** be reproducible and, to enforce it, `andrew` executes the calculations presents in [Jupyter Notebooks](https://nbformat.readthedocs.io/) and [R Markdown](https://rmarkdown.rstudio.com/) files in an [container](https://en.wikipedia.org/wiki/OS-level_virtualization).

The curation of tutorials or vignette that is included in the **static** website can be done using a [sibling project](https://github.com/GESIS-Methods-Hub/andrew-django-admin) or manually editting the CSV files.

![Workflow diagram ilustrating how andrew works.](img/workflow.drawio.png)

The collection is organised in two levels.

![Screenshot of demo showing the content of the "root".](img/andrew-root.png)

![Screenshot of demo showing the content of a 1st level collection.](img/andrew-1st-level.png)

![Screenshot of demo showing the content of of a 2nd level collection.](img/andrew-2nd-level.png)

![Screenshot of demo showing one document in the collection.](img/andrew-content.png)

## Dependencies

- [Docker](https://www.docker.com/)
- Quarto >= 1.3
- R
- Python
  - [repo2docker](https://repo2docker.readthedocs.io/)

### Dependencies installation

We recommend use [`mamba`](https://mamba.readthedocs.io/) to install the dependencies. A step by step is available at [the Contribution Guide](./CONTRIBUTING.md).

## Install `andrew`

```bash
Rscript -e "devtools::install('GESIS-Methods-Hub/andrew')"
```

## How to Build the Demo Website

```bash
Rscript -e "andrew::main(source_dir='demo')"
```

## Similar Projects

- [R Universe](https://r-universe.dev)
- [Gallery of Jupyter Books](https://executablebooks.org/en/latest/gallery/)
- [`matplotlib` Examples](https://matplotlib.org/stable/gallery/index.html)
