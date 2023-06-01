# methodshub

`methodshub` is designed to make it quick to build a website that show case a collection of tutorials or vignette of computational methods.

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