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
ADD ds-test.sh /root
CMD ["/bin/bash", "/root/ds-test.sh"]
#RUN npm install -g http-server
#CMD ["http-server", "-p", "8000"]
