Docker docker-compose image
===
An image to run docker-compose from within docker.
## Usage
```sh
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/rootfs/$PWD" -w="/rootfs/$PWD" --name="docker-compose" officerjones/compose
```
You may want to create an alias *docker-compose* for this so you can run the commands as you would on a regular install.
E.g.
```sh
	docker-compose build
	docker-compose up -d
	docker-compose down
	...
```
## Build
The image is built for arm architecture on a Raspberry Pi 3 B+.
You can build on your own platform using the Dockerfile for other architectures.
```sh
	docker build --tag <yourtag:yourversion> .
```