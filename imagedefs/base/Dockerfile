FROM archlinux/base:latest
#RUN pacman --noconfirm -Syu git-doc git-bash-completion 
RUN pacman --noconfirm -Syu bash bash-completion less tree git openssh dnsutils coreutils gawk sed grep

WORKDIR /

#RUN addgroup -g 1001 git
#RUN groupadd -g 1001 git

ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh /usr/local/sbin/git-prompt.sh
RUN chgrp git /usr/local/sbin/git-prompt.sh
RUN chmod ug+rx /usr/local/sbin/git-prompt.sh
#ADD https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash /usr/share/bash-completion/completions/git

RUN mkdir -p /etc/ssh
WORKDIR /etc/ssh

RUN \
   domains="github.com bitbucket.org ssh.dev.azure.com" ;                                                                                 \
   for domain in $domains ; do                                                                                                            \
     echo "The domain is: $domain" ;                                                                                                      \
     ssh-keyscan -t rsa $domain >>known_hosts ;                                                                                           \
     nslookup $domain | grep ^Address | awk '{print $2}' | xargs -n2 | awk '{print $2}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts ;    \
   done

##     nslookup $domain | grep ^Address | awk '{print $3}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts ;   \


#RUN exit 1
#RUN ssh-keyscan -t rsa github.com >>known_hosts
#RUN nslookup github.com | grep ^Address | awk '{print $2}' | xargs -n2 | awk '{print $2}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts

#RUN nslookup github.com | grep ^Address | awk '{print $3}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts
#RUN ssh-keyscan -t rsa bitbucket.org >>known_hosts
#RUN nslookup bitbucket.org | grep ^Address | awk '{print $3}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts
#RUN ssh-keyscan -t rsa ssh.dev.azure.com >>known_hosts
#RUN nslookup ssh.dev.azure.com | grep ^Address | awk '{print $3}' | xargs -n1 ssh-keyscan -t rsa >>known_hosts

RUN chgrp git known_hosts
RUN chmod ug+r known_hosts

WORKDIR /usr/local/sbin
ADD assets/git-credential-read-only .
RUN chgrp git git-credential-read-only
RUN chmod ug+rx git-credential-read-only
