setup:
	cp -Rn ./template/dictionaries/* ./editor/dictionaries

up:
	docker-compose up -d

db:
	docker-compose up -d mongo

attach_mongo:
	docker exec -it nibe_mongo /bin/bash

down:
	docker-compose down

restart:
	docker-compose restart

reload:
	docker-compose down
	docker-compose up -d

clean:
	rm -rf .mongo/*

status: 
	docker-compose ps

log:
	docker-compose logs