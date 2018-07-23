FROM alpine:3.8

MAINTAINER Sebastian Mangelkramer <sebastian@mangelkramer.com>

# install packages and cleanup
RUN apk update && \
apk add --no-cache ansible && \
apk add --no-cache git && \
apk add --no-cache python &&\
apk add --no-cache openssh &&\
apk add --no-cache terraform &&\
apk add --no-cache bzr &&\
apk add --no-cache go &&\
apk add --no-cache musl-dev &&\
apk add --no-cache bash &&\
rm -rf /tmp/* && \
rm -rf /var/cache/apk/*

# install runtastic opennebula terraform provider
RUN go get -v github.com/runtastic/terraform-provider-opennebula && \
    go install -v github.com/runtastic/terraform-provider-opennebula

# set opennebula driver in .terraformrc
RUN echo -e 'providers {\n\
 opennebula = "/root/go/bin/terraform-provider-opennebula"\n\
 }'\
>> /root/.terraformrc

# change from sh to bash 
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

# WORKDIR
WORKDIR /code

# clone kubespray repo
RUN git clone https://github.com/kubernetes-incubator/kubespray.git

# install requirements
RUN pip3 install -r kubespray/requirements.txt
# create ssh-keypair
RUN ssh-keygen -t rsa -f /code/id_rsa_kubespray -q -P ""
