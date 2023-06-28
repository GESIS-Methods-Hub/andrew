FROM rocker/r-ver:4.3.1 as pkgdown
RUN apt update && \
apt install -y \
make \
zlib1g-dev \
libcurl4-openssl-dev \
libssl-dev \
libfontconfig1-dev \
libfreetype6-dev \
libfribidi-dev \
libharfbuzz-dev \
libjpeg-dev \
libpng-dev \
libtiff-dev \
pandoc \
libicu-dev \
libxml2-dev \
git \
libgit2-dev \
&& \
apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
Rscript --verbose --vanilla \
-e 'install.packages("pkgdown", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
-e 'install.packages("devtools", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'