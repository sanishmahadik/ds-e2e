FROM alpine:3.5
RUN apk -v --update add \
        python \
        py-pip \
        && \
    pip install --upgrade awscli
ADD object-store-failure.sh /root
CMD ["/bin/sh", "/root/object-store-failure.sh"]
