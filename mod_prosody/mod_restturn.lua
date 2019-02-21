-- XEP-0215 implementation for time-limited turn credentials
-- Copyright (C) 2012-2013 Philipp Hancke
-- This file is MIT/X11 licensed.

local st = require "util.stanza";
local https = require "ssl.https";
local json = require "util.json";
local log = module._log;

local path_url = "/stun?api_key=";
local host =  module:get_option_string("rest_turn_host");
local api_key =  module:get_option_string("rest_turn_api_key");

module:log("debug", "Module loaded");

if not (api_key and host) then
    module:log("error", "rest turn not configured");
    return;
else
    module:log("info", "Module rest turn configured %s %s",api_key , host );
end

module:add_feature("urn:xmpp:extdisco:1");

function lastIndexOf(haystack, needle)
  local last_index = 0
  while haystack:sub(last_index+1, haystack:len()):find(needle) ~= nil do
    last_index = last_index + haystack:sub(last_index+1, haystack:len()):find(needle)
  end
  return last_index
end

module:hook("iq-get/host/urn:xmpp:extdisco:1:services", function(event)
    local origin, stanza = event.origin, event.stanza;
    if origin.type ~= "c2s" then
        return;
    end
    local get_url = host .. path_url .. api_key;
    local response_body = {};

    module:log("debug", "%s",get_url);

    local ret, code, headers, status = https.request{
        url = get_url,
        protocol = "tlsv1_1",
        sink = ltn12.sink.table(response_body),
    };

    local body = table.concat(response_body);
    module:log("debug", "%s %s %s",code, ret, body);

    local reply = st.reply(stanza);
    reply:tag("services", {xmlns = "urn:xmpp:extdisco:1"});
    if code == 200 then
        local stun_info = json.decode(body);
        local username = stun_info.username;
        local password = stun_info.password;
        local ttl = stun_info.ttl;
        log("debug", "INFO : %s %s %s", username, password, ttl);
        for index,value in ipairs(stun_info.uris) do
            log("debug", "Value  : %s ", value);
            local protocol_delimiter = string.find(value, ":");
            log("debug", "Delimiter  %d",protocol_delimiter);
            local port_delimiter  = lastIndexOf(value,":");
            log("debug", "Delimiter  %d",port_delimiter);
            local transport_delimiter = string.find(value, "?");
            log("debug", "Delimiter  %d",transport_delimiter);
            local transport_end_delimiter = string.find(value, "=");
            log("debug", "Delimiter  %d",transport_end_delimiter);

            local type = string.sub(value,0,protocol_delimiter-1);
            local server_host = string.sub(value,protocol_delimiter+1,port_delimiter-1);


            local port = string.sub(value,port_delimiter+1,transport_delimiter-1);
            local transport = string.sub(value,transport_end_delimiter+1);

            if index <= 10 then
                reply:tag("service", { type = type, host = server_host, port = port, transport = transport, username = username, password = password, ttl = ttl });
                reply:up();
            end
        end
        reply:up();
    end
    reply:up();
    log ("info","TURN info : %s", reply:pretty_print());
    origin.send(reply);
    return true;
end);
