FROM alpine:3.5
RUN apk -v --update add \
        python \
        py-pip \
        && \
    pip install --upgrade awscli
ADD ds-failure.sh /root
CMD ["/bin/sh", "/root/ds-failure.sh"]
