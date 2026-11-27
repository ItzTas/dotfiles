# `/healthz` is a static 200 that needs no auth. Never probe `/v1/models`: it rebuilds
# the whole model pool and takes 15s+ on a cold cache. The domain only resolves
# through the Pi-hole, so outside the LAN/tailnet this fails fast with a clear message.
function __omniroute_up --argument-names base_url
    curl -sf -m 3 -o /dev/null "$base_url/healthz"
end
