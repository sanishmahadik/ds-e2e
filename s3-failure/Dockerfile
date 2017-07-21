FROM alpine:3.5
RUN apk -v --update add \
        python \
        py-pip \
        && \
    pip install --upgrade awscli
ADD s3-failure.sh /root
CMD ["/bin/sh", "/root/s3-failure.sh"]
