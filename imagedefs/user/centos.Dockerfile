ARG BASEIMAGE=tqxridentity/centos-git-base:latest
FROM ${BASEIMAGE}

ARG LOGIN=nobody
ARG GIT_USERNAME="GIT USERNAME is not set"
ARG GIT_EMAIL="nobody@localhost"

ENV LOGIN ${LOGIN:-whatbirdisthat}
ENV GIT_USERNAME ${GIT_USERNAME:-'GIT USERNAME IS NOBODY'}
ENV GIT_EMAIL ${GIT_EMAIL:-'GIT EMAIL IS NOT SET'}

WORKDIR /

RUN mkdir -p \
/newroot/lib64/tls/x86_64/x86_64/ \
/newroot/bin \
/newroot/etc \
/newroot/etc/ssh \
/newroot/etc/pki \
/newroot/etc/services \
/newroot/usr/bin \
/newroot/usr/libexec \
/newroot/usr/share \
/newroot/usr/share/terminfo/x \
/newroot/usr/share/bash-completion/completions \
/newroot/usr/share/i18n \
/newroot/usr/share/i18n/charmaps \
/newroot/usr/share/i18n/repertoiremaps \
/newroot/usr/share/i18n/locales \
/newroot/usr/lib/locale \
/newroot/usr/local/sbin \
/newroot/home


RUN adduser -U $LOGIN
RUN mkdir -p /home/$LOGIN/.ssh

WORKDIR /usr/local/sbin
ADD assets/git-credential-read-only .
WORKDIR /
ADD assets/.bashrc /home/$LOGIN/
ADD assets/.gitexcludes /home/$LOGIN/
ADD assets/.gitconfig /home/$LOGIN/
RUN sed -i "s/GIT_USERNAME/${GIT_USERNAME}/" /home/$LOGIN/.gitconfig
RUN sed -i "s/GIT_EMAIL/${GIT_EMAIL}/" /home/$LOGIN/.gitconfig

RUN cp /etc/ssh/known_hosts /home/$LOGIN/.ssh/known_hosts

WORKDIR /

## for strace
# RUN cp /lib64/{\
# libdw.so.1,\
# libelf.so.1,\
# liblzma.so.5,\
# } /newroot/lib64


RUN cp /lib64/libtinfo.so.6 /newroot/lib64/tls/x86_64/x86_64/libtinfo.so.6

RUN cp /lib64/{\
ld-linux-x86-64.so.2,\
libacl.so.1,\
libassuan.so.0,\
libattr.so.1,\
libbz2.so.1,\
libc.so.6,\
libcap.so.2,\
libcom_err.so.2,\
libcrypt.so.1,\
libcrypto.so,\
libcrypto.so.1.1,\
libcurl.so.4,\
libdl.so.2,\
libfipscheck.so.1,\
libfreebl3.so,\
libgcc_s.so.1,\
libgcrypt.so.20,\
libgpg-error.so.0,\
libgssapi_krb5.so.2,\
libhistory.so.7,\
libidn.so.11,\
libk5crypto.so.3,\
libkeyutils.so.1,\
libkrb5.so.3,\
libkrb5support.so.0,\
liblber-2.4.so.2,\
libldap-2.4.so.2,\
libm.so.6,\
libnspr4.so,\
libnss3.so,\
libnss_dns.so.2,\
libnss_files.so.2,\
libnss_sss.so.2,\
libnssutil3.so,\
libpcre.so.1,\
libpcre2-8.so.0,\
libplc4.so,\
libplds4.so,\
libpthread.so.0,\
libreadline.so.7,\
libresolv.so.2,\
libsasl2.so.3,\
libselinux.so.1,\
libsmime3.so,\
libssl.so,\
libssl3.so,\
libutil.so.1,\
librt.so.1,\
libz.so.1\
} /newroot/lib64

## extended edition :)
# RUN cp /usr/bin/{\
# awk,\
# curl,\
# head,\
# ldd,\
# locale,\
# man,\
# sed,\
# strace,\
# tail,\
# } /newroot/usr/bin/

RUN cp /usr/bin/{\
bash,\
cat,\
cmp,\
coreutils,\
diff,\
git,\
grep,\
less,\
ls,\
ssh,\
tree,\
uniq,\
vi,\
whoami\
} /newroot/usr/bin/

RUN cp /bin/sh /newroot/bin/
RUN cp /usr/share/bash-completion/completions/git /newroot/usr/share/bash-completion/completions/git
RUN cp -r /usr/local/sbin/git-prompt.sh /newroot/usr/local/sbin/
RUN cp -r /usr/share/git-core /newroot/usr/share/git-core
RUN cp /etc/{nsswitch.conf,passwd,group,host.conf} /newroot/etc/
RUN cp -r /etc/pki/ /newroot/etc/pki/
RUN cp -r /etc/ssh/ /newroot/etc/ssh
RUN cp -r /usr/share/terminfo/x /newroot/usr/share/terminfo/
RUN cp -r /usr/share/i18n/charmaps/UTF-8.gz /newroot/usr/share/i18n/charmaps/
RUN cp -r /usr/lib/locale/en_AU.utf8 /newroot/usr/lib/locale
RUN cp -r /usr/share/i18n/locales/en_AU /newroot/usr/share/i18n/locales/
## locale reports this as in use but it isn't there
# RUN cp -r /usr/share/i18n/repertoiremaps /newroot/usr/share/i18n/

##
# And *this* is how to get a 100% score in `dive` :)
##

FROM scratch
ARG LOGIN
COPY --from=0 /newroot/ /

USER $LOGIN
COPY --from=0 --chown=1000:1000 /home/$LOGIN /home/$LOGIN

ENV LC_ALL=en_AU.utf8
ENV LANG=en_AU.utf8
ENV LANGUAGE=en_AU:en

## for finding ENOENT and etc
# CMD [ "/usr/bin/strace", "/usr/bin/bash" ]
CMD [ "/usr/bin/bash" ]
