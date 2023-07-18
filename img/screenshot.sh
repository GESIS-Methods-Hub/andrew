#/bin/bash
#
# Script to update screenshots
#
# Syntax:
# screenshot.sh /path/to/web-browser
#
# Example
#
# screenshot.sh chromium-browser

if [ "$#" -eq 0 ]
then
  echo "Browser to use is missing"
  exit 1
fi

$1 --headless --screenshot=img/methodshub-root.png demo/_site/index.html

$1 --headless --screenshot=img/methodshub-1st-level.png demo/_site/gallery/fundamentals/index.html

$1 --headless --screenshot=img/methodshub-2nd-level.png demo/_site/gallery/fundamentals/basic-setup/index.html

$1 --headless --screenshot=img/methodshub-content.png demo/_site/GESIS-Methods-Hub/minimal-example-md/index/index.html