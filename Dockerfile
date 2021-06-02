# Build container
FROM golang:1.16.2-buster AS build_base

ENV HUGO_VERSION 0.83.1
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.deb

RUN apt-get install git

WORKDIR /tmp

# Download and install hugo
RUN curl -sL -o /tmp/hugo.deb \
    https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    dpkg -i /tmp/hugo.deb && \
    rm /tmp/hugo.deb

COPY . .

RUN hugo

# Run container
FROM nginx AS run

ENV HUGO_BASEURL ${BASE_URL}

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app

VOLUME [ "/var/log/nginx" ]

COPY --from=build_base ./tmp/public .

EXPOSE ${HTTP_PORT}