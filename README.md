# egoaty/sshd
OpenSSH Server with support for multiple users authenticated by password or SSH-public-key.

## Users file

To create login users at container startup mount a user definition file to ```/login_users```.

The format of the ```login_users``` files is similar to those of the passwd(5) file with an additional field for the SSH public key:

```
<username>:[<password hash>]:[<UID>]:[<GUID>]:[<comment>]:[<home directory>]:[shell]:[<SSH public key>]
```

* One line per user.
* Empty lines and lines starting with ```#``` are ignored.
* All parameters except ```<username>``` are optional. You should provide either of ```<password hash>``` or ```<SSH public key>``` to be able to login.
* ```<UID>``` and ```<GID>```, if provided, must be >=1000.
* The ```<home directory>```, if provided, has to be under ```/home```.

To create the optional ```<password hash>``` run:

```
docker run --rm -it egoaty/sshd mkpasswd --salt <~6 random characters>
```

## Volumes

To persist the generated SSH host keys ```/local/etc/ssh``` is defined as a volume and should be mounted to a local store on startup.

In addition you might want to mount the ```/home``` and ```/var/log``` directory.

## Running the container

Docker compose example:

```
version: '2'

services:
  ssh:
    image: 'egoaty/sshd'
    volumes:
      - ./ssh/login_users:/login_users:ro
      - ./ssh/config:/local/etc/ssh/:rw
      - ./ssh/log:/var/log:rw
      - ./ssh/home:/home:rw
    restart: unless-stopped
```

**Note:** To improve security set the ```/local/etc/ssh/``` mount to ``ro`` after the first run.
