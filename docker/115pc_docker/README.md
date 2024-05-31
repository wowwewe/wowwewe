```sh
docker run -d -p $port:3000 --restart=always -v /xxxxxx:/config/Downloads/115download  -e PUID=1000 -e PGID=1000 --name 115pc wowaqly/115pc
```
