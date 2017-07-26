FROM alpine:3.5
RUN apk -v --update add \
        jq \
        curl \
        python \
        py-pip \
        && \
    pip install --upgrade awscli
ADD ds-success.sh /root
CMD ["/bin/sh", "/root/ds-success.sh"]
