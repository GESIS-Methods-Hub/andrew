# Exploration of ideas for Web Portal for the GESIS Methods Hub

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