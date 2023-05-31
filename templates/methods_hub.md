---
title: |
  $title$
$if(author)$
author:
$for(author)$
  - name: $author$
$endfor$
$endif$
$if(image)$
image: $image$
$else$
image: ../../../img/logos/methods_hub.png
$endif$
citation: true
method:
$if(github_https)$
  github_https: $github_https$
$endif$
$if(github_user_name)$
  github_user_name: $github_user_name$
$endif$
$if(github_repository_name)$
  github_repository_name: $github_repository_name$
$endif$
$if(git_hash)$
  git_hash: $git_hash$
$endif$
$if(git_date)$
  git_date: $git_date$
$endif$
$if(source_filename)$
  source_filename: $source_filename$
$endif$
$if(quarto_version)$
  quarto_version: $quarto_version$
$endif$
---

$body$