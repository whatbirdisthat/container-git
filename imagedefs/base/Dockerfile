FROM alpine:latest

RUN apk add --no-cache bash less tree \
  git git-doc git-bash-completion \
  openssh-client

WORKDIR /

RUN addgroup git
ADD https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh .
RUN sh gitflow-installer.sh install stable; rm gitflow-installer.sh

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh /usr/local/sbin/git-prompt.sh
RUN chgrp git /usr/local/sbin/git-prompt.sh
RUN chmod ug+rx /usr/local/sbin/git-prompt.sh

RUN mkdir -p /etc/ssh
WORKDIR /etc/ssh

RUN ssh-keyscan -t rsa github.com >>known_hosts
RUN nslookup github.com | grep ^Address | awk '{print $3}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts
RUN ssh-keyscan -t rsa bitbucket.org >>known_hosts
RUN nslookup bitbucket.org | grep ^Address | awk '{print $3}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts

RUN chgrp git known_hosts
RUN chmod ug+r known_hosts

WORKDIR /usr/local/sbin
ADD assets/git-credential-read-only .
RUN chgrp git git-credential-read-only
RUN chmod ug+rx git-credential-read-only
