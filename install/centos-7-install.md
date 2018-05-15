### Prerequisites
Before proceeding, you must have:

Deployed a Vultr CentOS 7 server instance from scratch.
Logged into your machine as a non-root user with sudo privileges.

### Update your CentOS 7 system
One of the Linux system administrator's best practices is keeping a system up to date. Install the latest stable packages, then reboot.
```bash
$ sudo yum install epel-release
$ sudo yum update
$ sudo reboot
```
When the reboot finishes, login with the same sudo user.

### Install Java
Before you can install Jenkins, you need to setup a Java virtual machine on your system. Here, let's install the latest OpenJDK Runtime Environment 1.8.0 using YUM:
```bash
$ sudo yum install java-1.8.0
```

### Install Jenkins
Use the official YUM repo to install the latest stable version of Jenkins
```bash
$ cd ~ 
$ sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
$ sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
$ yum install jenkins
```

### Start the Jenkins service and set it to run at boot time:
```bash
$ sudo systemctl start jenkins.service
$ sudo systemctl enable jenkins.service
```
