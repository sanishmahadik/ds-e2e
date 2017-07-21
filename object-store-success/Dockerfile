FROM alpine:3.5
RUN apk -v --update add \
        python \
        py-pip \
        && \
    pip install --upgrade awscli
ADD object-store-success.sh /root
CMD ["/bin/sh", "/root/object-store-success.sh"]
