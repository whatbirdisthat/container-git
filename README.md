# Github friendly git-in-a-container

### For cases where you have multiple accounts on Github / Bitbucket / Gitlab... etc

> This is for things like when you need to have a git identity that isn't the one
you've got hard-coded in your laptop's `~/.ssh/config` and etc.

> So you spin up a little _gitainer_ and change the username,
add a `id_rsa` and we're good.

> What it doesn't do *yet* is `gpg` signing etc

To make this thing work, try:

```bash
make help
```

That will print out a nice helpful help text. OR you could ...

```bash
LOGIN=yourlogin                               \
GIT_USERNAME='Friendly Name'                  \
GIT_EMAIL='the-email@the-place.org'           \
PRIVATE_KEY_LOCATION=$HOME/.ssh/my-key.key    \
make build
```

The above will create a container called `git-yourlogin` which can be spun up
using the command `git-yourlogin`. The command is created as a little shell
script in `/usr/local/bin/git-yourlogin`.

I use this to start a git-session (a minimal shell with git and git-flow) in
$PWD.

* Example:

  You are in a terminal and the PWD is `/home/you/projects` :

  ```bash
  $ pwd
  /home/you/projects
  $ git-yourlogin
  yourlogin@git /home/you/projects λ

  ```

Each user (identity) container is based on *Alpine Linux* (latest) and comes with:
  * `bash`
  * `less`
  * `tree`
  * `git-docs`
  * `git-completion`
  * `git-prompt`
  * `git-flow`
  * `openssh-client`

---

> TIP: I use `pass` to help me remember the commands to type so building things
is a little easier:

  ```bash
  cd ~/Containers/container-git && \
  echo `pass things/containers/build-github-container` | bash -s
  ```

  Cool huh?

---
