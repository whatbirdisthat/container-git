FROM centos:latest

RUN yum update -y 
RUN yum group install -y "Development Tools"
RUN yum install -y \
    bash less tree \
    readline \
    make strace man asciidoc xmlto \
    openssh bind-utils \
    curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-CPAN perl-devel

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

RUN yum install -y readline-devel
RUN yum install -y libssh libssh-devel

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
    /usr/local/sbin/git-prompt.sh
RUN chmod ugo+rx /usr/local/sbin/git-prompt.sh

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    /usr/share/bash-completion/completions/git
RUN chmod ugo+rx /usr/share/bash-completion/completions/git

CMD [ "/usr/bin/bash" ]
