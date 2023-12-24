ps:
	docker ps -a
up:
	docker-compose up -d
down:
	docker-compose down --remove-orphans
conf:
	docker-compose config
redis:
	docker-compose exec redis sh
mongo:
	docker-compose exec mongo bash
mongo-express:
	docker-compose exec mongo-express bash
memcached:
	docker-compose exec memcached sh
beanstalkd:
	docker-compose exec beanstalkd sh
.PHONY: ps up down conf redis mongo memcached beanstalkd
