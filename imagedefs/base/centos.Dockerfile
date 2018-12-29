FROM centos:latest

RUN yum update && \
    yum group install -y "Development Tools" && \
    yum install -y \
    bash less tree \
    readline readline-doc \
    make strace man asciidoc xmlto \
    openssh-client openssh-clients bind-utils \
    curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-CPAN perl-devel

RUN mkdir -p /etc/ssh
WORKDIR /etc/ssh

RUN ssh-keyscan -t rsa github.com >>known_hosts
RUN nslookup github.com | grep '^Address' | awk '{print $2}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts
RUN ssh-keyscan -t rsa bitbucket.org >>known_hosts
RUN nslookup bitbucket.org | grep '^Address' | awk '{print $2}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts

WORKDIR /

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
    /usr/local/sbin/git-prompt.sh
RUN chmod ugo+rx /usr/local/sbin/git-prompt.sh

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    /usr/share/bash-completion/completions/git
RUN chmod ugo+rx /usr/share/bash-completion/completions/git

RUN mkdir /mygit
WORKDIR /mygit
ADD https://github.com/git/git/archive/v2.20.1.tar.gz .
RUN tar xvf v2.20.1.tar.gz
WORKDIR /mygit/git-2.20.1
RUN make configure

# RUN ./configure --prefix=/usr \
#     --without-python \
#     --without-tcltk \
#     --without-iconv \
#     --without-openssl \
#     --without-curl \
#     --without-expat \
#     --without-libpcre1 \
#     --without-expat
# RUN make prefix=/usr profile
# RUN make prefix=/usr PROFILE=BUILD install
RUN ./configure --prefix=/usr
RUN NO_PERL=1 NO_PYTHON=1 NO_TCLTK=1 make install
# RUN make install-doc
WORKDIR /
CMD [ "/usr/bin/bash" ]
