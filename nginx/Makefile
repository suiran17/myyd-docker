build_ngx118yd:
	cp -R soft ./images/alpine/soft
	docker-compose build ngx118yd
	#docker-compose build --no-cache ngx118yd
	docker-compose push ngx118yd
	rm -rf ./images/alpine/soft
build_ngx119yd:
	cp -R soft ./images/alpine/soft
	docker-compose build ngx119yd
	#docker-compose build --no-cache ngx119yd
	docker-compose push ngx119yd
	rm -rf ./images/alpine/soft
test:
	docker-compose up test
