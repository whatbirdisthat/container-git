FROM archlinux/base:latest

RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S base-devel
RUN pacman --noconfirm -S openssl
RUN pacman --noconfirm -S openssh
RUN pacman --noconfirm -S git
RUN pacman --noconfirm -S bash
RUN pacman --noconfirm -S bash-completion
RUN pacman --noconfirm -S coreutils
RUN pacman --noconfirm -S gawk
RUN pacman --noconfirm -S sed
RUN pacman --noconfirm -S grep
RUN pacman --noconfirm -S less
RUN pacman --noconfirm -S tree
RUN pacman --noconfirm -S strace
RUN pacman --noconfirm -S dnsutils
# RUN pacman --noconfirm -S libselinux ## in AUR
RUN pacman --noconfirm -S libidn
RUN pacman --noconfirm -S nspr
RUN pacman --noconfirm -S base-devel

# FROM centos:latest

# RUN yum update -y 
# RUN yum group install -y "Development Tools" \
# RUN yum install -y \
#     bash less tree \
#     readline \
#     make strace man asciidoc xmlto \
#     openssh bind-utils \
#     curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-CPAN perl-devel

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

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
    /usr/local/sbin/git-prompt.sh
RUN chmod ugo+rx /usr/local/sbin/git-prompt.sh

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    /usr/share/bash-completion/completions/git
RUN chmod ugo+rx /usr/share/bash-completion/completions/git

WORKDIR /
CMD [ "/usr/bin/bash" ]
