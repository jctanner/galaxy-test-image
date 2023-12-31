FROM quay.io/centos/centos:stream9

RUN rpm -e --nodeps curl-minimal
RUN dnf install -y epel-release
RUN dnf install -y \
	ca-certificates \
	curl \
	g++ \
	gcc \
	git \
	gnupg2 \
	bzip2-devel \
	libffi-devel \
	readline-devel \
	sqlite-devel \
	libxml2-devel \
	libxslt-devel \
	libyaml \
	glibc-locale-source \
	make \
	openssh-clients \
	openssh-server \
	openssl \
	python3-pip \
	python3-devel \
	python3-distlib \
	python3.11 \
	python3.11-pip \
	python3.11-devel \
	libicu \
	libicu-devel \
	shellcheck \
	sudo \
	systemd-sysv \
    wget \
    openssl \
    openssl-devel \
    patch

# need py 3.6, 3.7, 3.10, 3.12
COPY files/install_python.sh /usr/bin/install_python.sh
RUN /usr/bin/install_python.sh 2.7
RUN /usr/bin/install_python.sh 3.5
RUN /usr/bin/install_python.sh 3.6
RUN /usr/bin/install_python.sh 3.7
RUN /usr/bin/install_python.sh 3.8
RUN /usr/bin/install_python.sh 3.10

RUN alternatives --install /usr/bin/python python /usr/bin/python3.11 1
RUN alternatives --set python /usr/bin/python3.11

# powershell sanity
COPY files/install_powershell.sh /tmp/install_powershell.sh
RUN /tmp/install_powershell.sh

# populate ansible-test paths and files
RUN git clone https://github.com/ansible/base-test-container /tmp/base-test-container
RUN ls -al /tmp/base-test-container
RUN mkdir -p /usr/share/container-setup
RUN cp /tmp/base-test-container/files/*.py /usr/share/container-setup/
RUN ln -s /usr/bin/python3.11 /usr/share/container-setup/python

# galaxy importer
RUN useradd user1 --uid=1000 --no-create-home --gid root
RUN mkdir -m 0775 -p /archive /ansible_collections/ns/col /.cache/pylint /eda/tox
RUN touch /ansible_collections/ns/col/placeholder.txt
RUN chown -R user1 /ansible_collections

RUN python3.9 -m pip install ansible-core==2.15.0 --disable-pip-version-check
RUN python3.9 -m pip install tox

RUN cd /ansible_collections/ns/col && HOME=/ ansible-test sanity --prime-venvs && chmod -R 0775 /.ansible
RUN rm -rf /ansible_collections

ENV container=docker
CMD ["/sbin/init"]
