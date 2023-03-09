# Exploration of ideas for Web Portal for the GESIS Methods Hub

## Dependencies

- R
  - devtools
- Quarto
- jupytext

## How to Build Portal

```bash
Rscript demetrius.R
```

## Steps to Process Contributions

`demetrius.R` will read `content-contributions.csv` and perform

1. Fetch contribution using Git
1. Convert Quarto document to HTML

The script's name is a reference to [Demetrius of Phalerum](https://en.wikipedia.org/wiki/Library_of_Alexandria).