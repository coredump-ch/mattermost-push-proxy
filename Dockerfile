# Docker file for mattermost-push-proxy.
#
# Instead of configuring this container through env vars,
# you should mount a `mattermost-push-proxy.json` config file
# into the container.
#
# The default path is at `/etc/mattermost-push-proxy.json`.
# If you decide to put the config file in a different location,
# you can specify the new location as a command line argument
# when starting the container.
#
# To run:
#
#   docker run \
#       -v $(pwd)/config/mattermost-push-proxy.json:/etc/mattermost-push-proxy \
#       coredump/mattermost-push-proxy:docker
#
# This is not an official Dockerfile, but maintained
# by Coredump Hackerspace (https://www.coredump.ch)!

FROM golang:1.12

# Add code
ADD . /code
RUN mkdir -p /go/src/github.com/mattermost \
    && ln -s /code /go/src/github.com/mattermost/mattermost-push-proxy

# Build
RUN cd /go/src/github.com/mattermost/mattermost-push-proxy && make build-server

# Package
RUN cd /go/src/github.com/mattermost/mattermost-push-proxy && make package

# Run tests
RUN cd /go/src/github.com/mattermost/mattermost-push-proxy && make test

# Copy server binary
RUN cp /go/bin/mattermost-push-proxy /usr/local/bin

# Add config
ADD config/mattermost-push-proxy.json /etc/mattermost-push-proxy.json

# Entry point
EXPOSE 8066
ENTRYPOINT ["mattermost-push-proxy", "-config"]
CMD ["/etc/mattermost-push-proxy.json"]
