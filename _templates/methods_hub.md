---
title: $title$
$if(author)$
author: $author$
$endif$
$if(image)$
image: $image$
$else$
image: ../../../img/logos/methods_hub.png
$endif$
method:
$if(github_https)$
  github_https: $github_https$
$endif$
$if(git_hash)$
  git_hash: $git_hash$
$endif$
$if(git_date)$
  git_date: $git_date$
$endif$
---

$body$