ARG BASEIMAGE=wbit/alpine-git-base
FROM ${BASEIMAGE}

WORKDIR /

ARG LOGIN=nobody
ARG GIT_USERNAME="Username is nobody"
ARG GIT_EMAIL="nobody@localhost"

RUN adduser -D -g '' ${LOGIN}
RUN addgroup ${LOGIN} git

WORKDIR /home/${LOGIN}
ADD assets/.bashrc .
ADD assets/.gitexcludes .

RUN mkdir /home/${LOGIN}/.ssh
WORKDIR /home/${LOGIN}/.ssh
RUN cat /etc/ssh/known_hosts > /home/${LOGIN}/.ssh/known_hosts
RUN chmod 0400 /home/${LOGIN}/.ssh/known_hosts

WORKDIR /home/${LOGIN}
RUN chown -R ${LOGIN} /home/${LOGIN}

USER ${LOGIN}

RUN git config --global user.name "${GIT_USERNAME}"
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global credential.helper 'read-only'
RUN git config --global color.status always

ENTRYPOINT /bin/bash
