# Baikonur

Following instructions are to bootstrap a development environment for running Baikonur

## Dependencies

1. Install systemd-nspawn and debootstrap (https://wiki.debian.org/nspawn)
1. Fetch the ubuntu image for the container: sudo debootstrap focal /var/lib/machines/<name> http://archive.ubuntu.com/ubuntu
1. Set up the base image for deployment (https://clinta.github.io/getting-started-with-systemd-nspawnd/)

Note: <name> refers to the name of the development container for running Baiknour
1. Prepare the DNS server
1. Allow future logins with a preset password
1. Optionally remove the step below to remove `securetty`. There is a bug which is to be addressed in machinectl, and this is a temporary hack to avoid the annoying lockout after setting up a password in the bootstrap
1. Optionally allow port forwarding within the container, in case there is no internet access

```
$ rm /var/lib/machines/<name>/etc/hostname \ # Disable the hostname or enter a custom login name
$ sudo bash -c 'echo "nameserver 8.8.8.8" >> /var/lib/machines/<name>/etc/resolv.conf'
$ sudo bash -c 'echo "pts/0" >> /var/lib/machines/<name>/etc/securetty'
$ rm /var/lib/machines/<name>/etc/securetty
$ sudo bash -c 'echo "net.ip4.forward = 1" >> /var/lib/machines/<name>/etc/sysctl.d/ip_forward.conf'
$ sudo bash -c 'echo "deb http://archive.ubuntu.com/ubuntu focal main multiverse universe restricted
" >> /var/lib/machines/<name>/etc/apt/sources.list'
```

## Running Baikonur as a container

1. To deploy use machinectl to start the container: `machinectl start <container-name>`

1. Copy over val-verde source deb packages: `machinectl copy-to <name> /path/to/host/dir /root/path/to/<name>/destination/dir`
Note: Remove the following packages: 
`val-verde-libunwind-gnu-haswell.deb 
val-verde-libunwind-mingw32-haswell.deb 
val-verde-libcxx-gnu-haswell.deb 
val-verde-libcxx-mingw32-haswell.deb 
val-verde-libcxxabi-gnu-haswell.deb 
val-verde-libcxxabi-mingw32-haswell.deb`

1. Install the dependencies:

```
$ apt update
$ apt upgrade -y
$ apt install -y libatomic1 libc6-dev libedit2 libmpfr6 libnvidia-compute-440
$ cd /root/path/to/<name>/destination/dir
$ dpkg -i /*.deb
```

## Configure the web server

1. Set up the nspawn service on the host `systemd-nspawn@<name>`:
```
echo cat >> EOF
[Exec]
PrivateUsers=pick

[Network]
Zone=<name>
Port=tcp:443
Port=tcp:8080

[Files]
PrivateUsersChown=yes
EOF
$ sudo systemctl enable systemd-nspawn@<name>

```

1. Set up environment for the swift app:

```
$ export PACKAGE_PREFIX=/usr/local/val-verde-platform-sdk-gnu-haswell/sysroot
$ export PATH=${PACKAGE_PREFIX}/usr/bin:${PACKAGE_PREFIX}/usr/sbin
$ export PATH=$PATH:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
$ export LD_LIBRARY_PATH=${PACKAGE_PREFIX}/usr/lib:${PACKAGE_PREFIX}/usr/lib/swift/linux
$ export GIT_EXEC_PATH=${PACKAGE_PREFIX}/usr/libexec/git-core
```

1. Fetch Baikonur source code

```
$ mkdir /root/projects
$ cd /root/projects
$ git clone https://github.com/val-verde/baikonur.git --branch master --single-branch .
```

1. Build & run the vapor server:

```
$ swift build -Xswiftc -I/usr/local/val-verde-platform-sdk-gnu-haswell/sysroot/usr/include
$ swift run
```

## Run the web server

1. Install nginx server to forward the ports 80 to 8080 - the default port for the web server
1. Navigate to the IPv4 of the container `machinectl list <name> -l` on the browser for a successful image

## References:

1. https://medium.com/@huljar/setting-up-containers-with-systemd-nspawn-b719cff0fb8d
1. https://blog.selectel.com/systemd-containers-introduction-systemd-nspawn/
1. https://github.com/systemd/systemd/issues/852
1. https://unix.stackexchange.com/questions/411622/systemd-nspawn-redirect-ports-and-keep-internet

## Todo:

1. Consolidate build of baikonur as a deb package
1. Store sources in talam
1. Update the https end point by setting up openssl certs
