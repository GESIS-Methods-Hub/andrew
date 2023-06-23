# `methodshub` R package

Create portal from collection of Quarto and Jupyter documents.

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

### Dependencies installation with `micromamba`

[Check the Contribution Guide](CONTRIBUTING.md#how-to).

## How to Build Demo Portal

```bash
Rscript -e "devtools::load_all(); methodshub::main(source_dir='demo')"
```