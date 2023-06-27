FROM rocker/r-ver:4.3.1 as pkgdown
RUN Rscript --verbose --vanilla -e 'install.packages("pkgdown")' -e 'install.packages("devtools")'