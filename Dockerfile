FROM amazonlinux:2022

ARG SSH_ROOT_PASSWORD=${SSH_ROOT_PASSWORD:-root}
ARG SSH_USER=${SSH_USER:-ec2-user}
ARG SSH_PASSWORD=${SSH_PASSWORD:-ec2-user}

ENV SSH_ROOT_PASSWORD=${SSH_ROOT_PASSWORD}
ENV SSH_USER=${SSH_USER}
ENV SSH_PASSWORD=${SSH_PASSWORD}
ENV TZ=Asia/Seoul

RUN echo $TZ > /etc/timezone

USER root

RUN yum install -y -q passwd sudo shadow-utils openssh-server \
    net-tools iputils vim \
    git findutils authconfig \
    && yum clean all \
    && rm -rf /var/cache/dnf

RUN echo "root:$SSH_ROOT_PASSWORD" | chpasswd \
    && cp -rf /etc/skel/.bash* /root/. \
    && echo 'export PS1="\[\033[01;32m\]\u\[\e[m\]\[\033[01;32m\]@\[\e[m\]\[\033[01;32m\]\h\[\e[m\]:\[\033[01;34m\]\W\[\e[m\]$ "' >> ~/.bashrc \
    && ssh-keygen -A

RUN useradd -m -c "$SSH_USER" -d /home/$SSH_USER -s /bin/bash $SSH_USER \
    && echo "$SSH_USER:$SSH_PASSWORD" | chpasswd \
    && usermod -aG wheel $SSH_USER \
    && echo 'export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "' >> /home/$SSH_USER/.bashrc \
    && echo -e "$SSH_USER\tALL=(ALL)\tNOPASSWD:ALL" >> /etc/sudoers

### aws ec2 sshd_config 설정
COPY config/ec2-sshd_config /etc/ssh/sshd_config

RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config \
    && sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config \
#     && sed -i 's/#UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config \
#     # 호스트 키 파일을 사용하도록 SSH 설정 변경
#     # && sed -i 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config \
#     # && sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config \
#     # && sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config \
#     && echo "AuthenticationMethods publickey,password" >> /etc/ssh/sshd_config \
#     && echo "PubkeyAcceptedAlgorithms +ssh-rsa" >> /etc/ssh/sshd_config \
    && mkdir /run/sshd

CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22
