# Load Lua module and healthcheck library
lua_package_path "/usr/local/openresty/lualib/resty/upstream/healthcheck/?.lua;;";
lua_shared_dict healthcheck 1m;
lua_socket_log_errors off;
 
init_worker_by_lua_block {
    local hc = require "resty.upstream.healthcheck"

    -- Function to retrieve servers from the upstream block
    local function get_upstream_servers(upstream_name)
        local servers = {}
        local u = require("ngx.upstream")
        local peers, err = u.get_primary_peers(upstream_name)

        if not peers then
            ngx.log(ngx.ERR, "failed to get primary peers: ", err)
            return servers
        end

        for _, peer in ipairs(peers) do
            -- Check if peer has valid name and port
            if peer.name then
                table.insert(servers, { name = peer.name })
            else
                ngx.log(ngx.ERR, "Peer missing name or port: ", peer.name, ";")
            end
        end

        return servers
    end

    local u = require("ngx.upstream")
    local upstreams = u.get_upstreams()
    -- local upstream_name = "usb-hitradex.com"
    -- local url_health = "/egw/api/healthcheck"
    local prefix_ups = "${US_PREFIX_BACKEND}"
    local url_health = "${US_URL_HEALTH_BACKEND}"

    -- Filter upstream names that start with prefix_ups
    for _, upstream_name in ipairs(upstreams) do
        if upstream_name:sub(1, #prefix_ups) == prefix_ups then
            ngx.log(ngx.ERR, "Filtered Upstream found: ", upstream_name)

            -- Get servers dynamically from the upstream group
            local servers = get_upstream_servers(upstream_name)

            -- Create health checks for each server
            for _, server in ipairs(servers) do
                local http_req = "GET " .. url_health .. " HTTP/1.0\r\nHost: " .. server.name .. "\r\n\r\n"
                local ok, err = hc.spawn_checker{
                    shm = "healthcheck",
                    upstream = upstream_name,
                    peer = server.name,
                    type = "http",
                    http_req = http_req,
                    port = server.port,
                    interval = 2000,
                    timeout = 1000,
                    fall = 5,
                    rise = 2,
                    valid_statuses = {200, 302},
                    concurrency = 10,
                }

                if not ok then
                    ngx.log(ngx.ERR, "failed to spawn health checker for server ", server.ip, ": ", err)
                    return
                end
            end

        end
    end

}
