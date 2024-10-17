#!/bin/bash

cd ./minimal_example || exit
sudo quarto render
sudo cp -r /home/dehnejn/gitlab/andrew/minimal_example/_site/* /var/minimal
sudo chown -R www-data:www-data /var/minimal/*
sudo chmod -R 755 /var/minimal/*
sudo systemctl restart nginx


