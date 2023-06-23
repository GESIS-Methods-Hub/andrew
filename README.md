# methodshub

`methodshub` is designed to make it quick to build a website that shows a collection of tutorials or vignette of **transparent analytics** computational methods. Tutorials and vignette **must** be reproducible and, to enforce it, `methodshub` executes the calculations in an [container](https://en.wikipedia.org/wiki/OS-level_virtualization).

The collection is organised in two levels.

![Screenshot of demo showing the content of the "root".](img/methodshub-root.png)

![Screenshot of demo showing the content of a 1st level collection.](img/methodshub-1st-level.png)

![Screenshot of demo showing the content of of a 2nd level collection.](img/methodshub-2nd-level.png)

![Screenshot of demo showing one document in the collection.](img/methodshub-content.png)

## Dependencies

- Quarto >= 1.3
- R
  - devtools
- Python
  - [repo2docker](https://repo2docker.readthedocs.io/)
  - [jupytext](https://jupytext.readthedocs.io/)

### Dependencies installation

We recommend use [`mamba`](https://mamba.readthedocs.io/) to install the dependencies. A step by step is available at [the Contribution Guide](./CONTRIBUTING.md).

## How to Build the Website

```bash
Rscript -e "devtools::load_all(); methodshub::main(source_dir='demo')"
```