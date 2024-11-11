#!/bin/bash

cd ./demo || exit
sudo quarto render
sudo cp -r /home/dehnejn/gitlab/andrew/demo/_site/* /var/www
sudo chown -R www-data:www-data /var/www/*
sudo chmod -R 755 /var/www/*
sudo systemctl restart nginx


