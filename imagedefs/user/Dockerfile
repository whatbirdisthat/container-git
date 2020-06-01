ARG BASEIMAGE=wbit/tqxr-git-base
FROM ${BASEIMAGE}

ARG LOGIN_UID=1000

WORKDIR /

ARG LOGIN=nobody
ARG GIT_USERNAME="Username is nobody"
ARG GIT_EMAIL="nobody@localhost"

RUN useradd --uid ${LOGIN_UID} ${LOGIN}
RUN usermod -aG git ${LOGIN}

WORKDIR /home/${LOGIN}
ADD assets/.bashrc .
ADD assets/.gitexcludes .

RUN mkdir /home/${LOGIN}/.ssh
WORKDIR /home/${LOGIN}/.ssh
RUN cat /etc/ssh/known_hosts > /home/${LOGIN}/.ssh/known_hosts
RUN chmod 0600 /home/${LOGIN}/.ssh/known_hosts

WORKDIR /home/${LOGIN}
RUN chown -R ${LOGIN} /home/${LOGIN}

USER ${LOGIN}

RUN git config --global user.name "${GIT_USERNAME}"
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global credential.helper 'read-only'
RUN git config --global color.status always

ENTRYPOINT /bin/bash
