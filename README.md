# Exploration of ideas for Web Portal for the GESIS Methods Hub

Preview: http://methods-hub.git.gesis.org/portal

## Dependencies

- R
  - devtools
- Quarto
- jupytext

## How to Build Portal

Update the content:

```bash
Rscript demetrius.R
```

Update the listings:

```bash
Rscript hans.R
```

## Steps to Process Contributions

`demetrius.R` will read `content-contributions.csv` and perform

1. Fetch contribution using Git
1. Convert Quarto document to HTML

The script's name is a reference to [Demetrius of Phalerum](https://en.wikipedia.org/wiki/Library_of_Alexandria).

## Steps to Process Listings

`hans.R` will read `zettelkasten.csv` and perform

1. Create `index.md` files for each topic
1. Create `listing-contents*.yml` for each topic

The script's name is a reference to [Hans Blumenberg](https://en.wikipedia.org/wiki/Hans_Blumenberg).

