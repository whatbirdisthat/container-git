FROM centos:latest

RUN yum update -y
RUN yum group install -y "Development Tools"
RUN yum install -y sssd-client
RUN yum reinstall -y asciidoc
RUN yum reinstall -y bash
RUN yum install -y bind-utils
RUN yum reinstall -y curl
RUN yum install -y curl-devel
RUN yum install -y expat-devel
RUN yum reinstall -y gettext-devel
RUN yum reinstall -y glibc-common
RUN yum reinstall -y glibc-langpack-en
RUN yum install -y glibc-locale-source
RUN yum reinstall -y less
RUN yum install -y libssh
RUN yum install -y libssh-devel
RUN yum reinstall -y make
RUN yum install -y man
RUN yum reinstall -y openssh
RUN yum install -y openssl-devel
RUN yum install -y perl-CPAN
RUN yum reinstall -y perl-devel
RUN yum reinstall -y readline
RUN yum install -y readline-devel
RUN yum reinstall -y strace
RUN yum install -y tree
RUN yum install -y which
RUN yum install -y xmlto
RUN yum reinstall -y zlib-devel

RUN localedef -f UTF-8 -i en_AU en_AU.utf8
ENV LC_ALL=en_AU.utf8

RUN mkdir -p /etc/ssh
WORKDIR /etc/ssh
RUN \
   domains="github.com bitbucket.org ssh.dev.azure.com" ;                                                                                 \
   for domain in $domains ; do                                                                                                            \
     echo "The domain is: $domain" ;                                                                                                      \
     ssh-keyscan -t rsa $domain >>known_hosts ;                                                                                           \
     nslookup $domain | grep ^Address | awk '{print $2}' | xargs -n2 | awk '{print $2}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts ;    \
   done

WORKDIR /

RUN mkdir /mygit
WORKDIR /mygit
ADD https://github.com/git/git/archive/v2.20.1.tar.gz .
RUN tar xvf v2.20.1.tar.gz
WORKDIR /mygit/git-2.20.1
RUN make -j 6 configure

RUN ./configure --prefix=/usr
RUN NO_PERL=1 NO_PYTHON=1 NO_TCLTK=1 make -j 6 install

WORKDIR /

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
    /usr/local/sbin/git-prompt.sh
RUN chmod ugo+rx /usr/local/sbin/git-prompt.sh

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    /usr/share/bash-completion/completions/git
RUN chmod ugo+rx /usr/share/bash-completion/completions/git

CMD [ "/usr/bin/bash" ]
