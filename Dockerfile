
FROM ubuntu:24.04

# Evitar preguntas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar SSH, sudo y Python
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio necesario para SSH
RUN mkdir -p /run/sshd

# Crear usuario ansible con contraseña ansible
RUN useradd -m -s /bin/bash ansible \
    && echo 'ansible:ansible' | chpasswd

# Dar privilegios sudo sin contraseña
RUN usermod -aG sudo ansible \
    && echo 'ansible ALL=(ALL) NOPASSWD:ALL' \
    > /etc/sudoers.d/ansible \
    && chmod 0440 /etc/sudoers.d/ansible

# Permitir autenticación SSH con contraseña
RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Puerto SSH
EXPOSE 22

# Iniciar servidor SSH
CMD ["/usr/sbin/sshd", "-D"]
