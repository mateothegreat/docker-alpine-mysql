NAME	= appsoa/alpine-mysql
ALIAS	= mysql
VERSION	= 1.0.0
DATA_DIR= /workspace/.data/alpine-mysql
MYSQL_DATABASE = db
MYSQL_USER = sql
MYSQL_PASSWORD = changeme
MYSQL_ROOT_PASSWORD = P@55w0rd!!

.PHONY:	all build test tag_latest release ssh

all:	clean build run

build:

	@echo "Building an image with the current tag $(NAME):$(VERSION).."
	@docker build -t $(NAME):$(VERSION) --rm .

clean: 	docker-current-clean-containers docker-current-clean-images docker-current-clean-volumes docker-global-clean-images

run:

	@docker run	-p 3306:3306 -v $(DATA_DIR):/data \
				-e MYSQL_DATABASE=${MYSQL_DATABASE:-"db"} \
				-e MYSQL_USER=${MYSQL_USER:-"sql"} \
				-e MYSQL_PASSWORD=${MYSQL_PASSWORD:-"changeme"} \
				-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"P@55w0rd!!"} \
				-d --rm --name $(ALIAS) $(NAME):$(VERSION)

logs:

	@docker logs -f --tail all $(ALIAS)
	
client:

	mysql -h 127.0.0.1 -u root -p$(MYSQL_ROOT_PASSWORD)

tag_latest:

	docker tag $(NAME):$(VERSION) $(NAME):latest

release:

	docker push $(NAME)

test:

	./test.sh $(NAME):$(VERSION)

docker-current-clean-containers:

	@echo "Deleting container(s) with the current tag $(NAME):$(VERSION).."
	@docker ps -a | grep $(ALIAS) | xargs --no-run-if-empty docker rm -f

docker-current-clean-images:

	@echo "Deleting image(s) with the current tag $(NAME):$(VERSION).."
	@docker images -a | grep $(NAME):$(VERSION) | xargs --no-run-if-empty docker rmi -f

docker-current-clean-volumes:

	@echo "Deleting volumes(s) with the current tag $(NAME):$(VERSION).."
	@docker volume ls -q | grep $(NAME):$(VERSION) | xargs -r docker volume rm || true

docker-global-clean-images:

	@echo "Deleting images that are not tagged.."
	@docker images | grep \<none\> | awk -F " " '{print $3}' | xargs --no-run-if-empty docker rmi

docker-images-list:

	@echo "Listing image(s) matching the current repo \"$(NAME)\" and the tag \"$(VERSION)\".."
	@docker images -a | grep $(NAME) | grep $(VERSION) || true

	@echo "Listing any other images matching current repo \"$(NAME)\":"
	@docker images -a | grep $(NAME) | grep -v $(VERSION) || true
