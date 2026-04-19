FROM ghcr.io/ptero-eggs/yolks:wine_staging

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]