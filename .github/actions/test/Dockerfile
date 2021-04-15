FROM pixl8/docker-commandbox-lite:v2-rc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# we need node, hence not using the regular testbox action
RUN apk update && apk add nodejs && \
    rm -f /var/cache/apk/*

ENTRYPOINT ["/entrypoint.sh"]