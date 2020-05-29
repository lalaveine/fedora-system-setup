FROM registry.fedoraproject.org/fedora:32

ENV NAME=fedora-toolbox VERSION=32
LABEL com.github.containers.toolbox="true" \
      com.github.debarshiray.toolbox="true" \
      com.redhat.component="$NAME" \
      name="$FGC/$NAME" \
      version="$VERSION" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Base image for creating Fedora toolbox containers" \
      maintainer="Debarshi Ray <rishi@fedoraproject.org>"

RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
COPY repos/vscode.repo /etc/yum.repos.d/

RUN dnf -y upgrade

COPY missing-docs /
RUN dnf -y reinstall $(<missing-docs)
RUN rm /missing-docs

COPY extra-packages /
RUN dnf -y install $(<extra-packages)
RUN rm /extra-packages

COPY dev-packages /
RUN dnf -y install $(<dev-packages)
RUN rm /dev-packages

RUN dnf clean all

CMD /bin/sh
