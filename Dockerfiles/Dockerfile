FROM ubuntu:latest

# Install system dependencies
RUN apt update && apt install -y python3 ansible nginx curl gnupg 
RUN apt full-upgrade -y && apt autoremove -y

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN mkdir -p /root/code
WORKDIR /root/code
COPY .env .
COPY start.sh . 

COPY index.html /var/www/html/index.html
COPY docker.png /var/www/html/docker.png

RUN chmod +x /root//code/start.sh
RUN echo "source /root/code/.env" >> /root/.bashrc

# Expose ports
EXPOSE 8080
EXPOSE 80

# Start code-server and nginx during container runtime
CMD ["/root/code/start.sh"]
