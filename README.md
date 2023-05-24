# Exploration of ideas for Web Portal for the GESIS Methods Hub

Preview: http://methods-hub.git.gesis.org/portal

## Dependencies

- Quarto >= 1.3
- R
  - devtools
- Python
  - [repo2docker](https://repo2docker.readthedocs.io/)
  - [jupytext](https://jupytext.readthedocs.io/)

## How to Build Demo Portal

```bash
Rscript -e "methodshub::main(source_dir='demo')"
```