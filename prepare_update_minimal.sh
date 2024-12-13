sudo chmod -R 777 .
docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep '^andrew/' | awk '{print $2}' | xargs docker rmi -f
sudo chmod -R 777 .
sudo rm -f minimal_example/_github
sudo rm -f minimal_example/github
sudo chmod -R 777 .

