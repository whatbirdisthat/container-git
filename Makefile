item = git
repo = tqxr
base_image = $(repo)/alpine-$(item)-base
binloc = ${HOME}/bin/
executable_name =$(item)-$(LOGIN)-$(SERVICE_NAME)

ifndef CONTAINER_NAME
CONTAINER_NAME:=$(repo)/$(item)-$(LOGIN)-$(SERVICE_NAME)
endif

ifndef GIT_CREDENTIALS_LOCATION
GIT_CREDENTIALS_LOCATION:=/dev/null
endif

ifndef DOCKERFILE
DOCKERFILE:=Dockerfile
endif

ALPINE_UPDATED:=Downloaded newer image for alpine:latest
LABEL_FILTER:=label=git-user-identity

check:
	cd imagedefs/base && docker run --rm -i hadolint/hadolint < Dockerfile
	cd imagedefs/user && docker run --rm -i hadolint/hadolint < Dockerfile

# --squash (experimental for now)

check-build-base-image:
	@{                                                                           \
	docker images | grep -q '$(base_image)' && exit 0 ;                          \
	docker pull alpine:latest | grep -vq '$(ALPINE_UPDATED)' || exit 0 ;         \
	echo "Building BASE image '$(base_image)'";                                  \
	cd imagedefs/base &&                                                         \
	docker build                                                                 \
	--rm \
	--label "git-base-image"                                                     \
	-t $(base_image) . ;                                                         \
	}

build-user-image:
	@{                                                                           \
	docker images | grep -q '$(CONTAINER_NAME)' && exit 0 ;                      \
	echo "*** BUILDING $(CONTAINER_NAME) IMAGE ***" &&                           \
	cd imagedefs/user &&                                                         \
	docker build --rm -t $(CONTAINER_NAME)                              \
	--label "git-user-identity"                                                  \
	--file "$(DOCKERFILE)"                                                       \
	--build-arg BASEIMAGE=$(base_image)                                          \
	--build-arg LOGIN="$(LOGIN)"                                                 \
	--build-arg GIT_USERNAME="$(GIT_USERNAME)"                                   \
	--build-arg GIT_EMAIL="$(GIT_EMAIL)"                                         \
	. ;                                                                          \
	}

remove-user-images:
	@{                                                                           \
	THEREPO=$(repo) ;                                                            \
	THEIMAGES=`docker images -q $${THEREPO}/* --filter "$(LABEL_FILTER)"` ;      \
	if [ "x$${THEIMAGES}" != "x" ]; then                                         \
	  docker rmi `docker images -q $${THEREPO}/* --filter "$(LABEL_FILTER)"` ;   \
	fi                                                                           \
	}

check-user-image-variables:
ifndef LOGIN
	$(error NO LOGIN)
endif
ifndef SERVICE_NAME
	$(error NO SERVICE -eg github, bitbucket etc)
endif
ifndef GIT_USERNAME
	$(error NO GIT USERNAME)
endif
ifndef GIT_EMAIL
	$(error NO GIT EMAIL)
endif

define RUN_COMMAND
#!/bin/bash
docker run -it --rm                                                            \
-v $(PRIVATE_KEY_LOCATION):/home/$(LOGIN)/.ssh/id_rsa                          \
-v $(GIT_CREDENTIALS_LOCATION):/home/$(LOGIN)/.git-credentials                 \
-v `pwd`:`pwd`                                                                 \
-w `pwd`                                                                       \
-h $(SERVICE_NAME).local                                                               \
$(CONTAINER_NAME)
endef

export RUN_COMMAND
build-container-command: check-user-image-variables build-user-image
	@echo "$$RUN_COMMAND" > "$(binloc)$(executable_name)"
	@chmod u+x "$(binloc)$(executable_name)"

install: check-build-base-image
	@:

build: install build-container-command
	@:

distclean: uninstall
	@rm -f $(binloc)$(executable_name)

clean: remove-user-images
	@:

uninstall: remove-user-images
	@docker rmi $(base_image)

define HELP_TEXT
GIT CONTAINER THINGY

Build containers for your git identities.

Setting up git on a developer workstation can be tangled if the developer has
multiple git identities (say, github, bitbucket, corporate gits etc).

One way to untangle this and keep git identities separated is to use containers.

Each user (identity) container is based on an image that runs alpine linux, with
openssh-client, git-docs, git-completion, git-prompt and git-flow. Also baked in
are bash, less and tree.

Examples:

1.
Simple git container using bare minimums

  LOGIN=loginusername                                   \
	SERVICE_NAME='github'                                 \
	GIT_USERNAME='Friendly Name For Commits'              \
	GIT_EMAIL='email@address.tld'                         \
	make install

The above will create an image called git-loginusername and put an executable
script into /usr/local/bin/git-loginusername which will fire up a container in
$PWD, bind-mounting the private key `$HOME/.ssh/id_rsa`.

2.
To use another key, set PRIVATE_KEY_LOCATION on the command line:

  LOGIN=loginusername                                   \
	SERVICE_NAME='github'                                 \
  GIT_USERNAME='Friendly Name For Commits'              \
  GIT_EMAIL='email@address.tld'                         \
  PRIVATE_KEY_LOCATION=$HOME/.ssh/my-key.key            \
  make install


3.
For HTTPS based authentication set GIT_CREDENTIALS_LOCATION on the command line.

  LOGIN=login                                            \
	SERVICE_NAME='github'                                 \
	GIT_USERNAME="Friendly Login Name"                     \
	GIT_EMAIL='hidden-email@users.noreply.github.com'      \
	PRIVATE_KEY_LOCATION=$HOME/.ssh/github.key             \
	GIT_CREDENTIALS_LOCATION=~/.github-git-credentials     \
	make install

4.
You might want to use a different Dockerfile for the user build (say, your org
has a bunch of certificates that need to be added) - this can be accomplished
using the DOCKERFILE env var eg: dockerfile in imagedefs/user/Dockerfile-custom

  LOGIN=login                                            \
	SERVICE_NAME='github'                                 \
	GIT_USERNAME="Friendly Login Name"                     \
	GIT_EMAIL='hidden-email@users.noreply.github.com'      \
	PRIVATE_KEY_LOCATION=$HOME/.ssh/github.key             \
	GIT_CREDENTIALS_LOCATION=~/.github-git-credentials     \
	DOCKERFILE=Dockerfile-custom                           \
	make install

endef
export HELP_TEXT

help:
	$(info $(HELP_TEXT))
	@:

.PHONY: all clean help
