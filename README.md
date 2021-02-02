# docker-sshd
OpenSSH server

## Users file

To create login users at container startup mount a file to ```/login_users```.

Format of the file:

```
<username>:[<password hash>]:[<UID>]:[<GUID>]:[<comment>]:[<home directory>]:[shell]:[<SSH public key>]
```

* One line per user.
* Empty lines and lines starting with # are ignored.
* All parameters except ```<username>``` are optional. You should provide either of ```<password hash>``` or ```<SSH public key>``` to be able to login.
* ```<UID>``` and ```<GID>``` must be >=1000.
* The ```<home directory>``` has to be under ```/home```.

To create the optional ```<password hash>``` run:

```
docker run --rm -it egoaty/sshd mkpasswd --salt <~6 random characters>
```

