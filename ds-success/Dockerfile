FROM alpine:3.5
RUN apk -v --update add \
        jq \
        bash \
        curl \
        python \
        py-pip \
        nodejs \
        && \
    pip install --upgrade awscli
ADD ds-success.sh /root
CMD ["/bin/sh", "/root/ds-success.sh"]
# RUN npm install -g http-server
# CMD ["http-server", "-p", "8000"]
