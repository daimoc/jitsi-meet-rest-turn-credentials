# Motivation
This project is made to provide configuration files for running a Jitsi Meet server with REST API For Access To TURN Services like described in this [draft](https://tools.ietf.org/html/draft-uberti-behave-turn-rest-00).

By now, it's design to get TURN credentials from  the [GEANT TURN FEDERATION](http://turn.geant.org/) project using [XEP-0215](https://xmpp.org/extensions/xep-0215.html) mechanism. It's build using documentation from  [jitsi-meet turn configuration documentation](https://github.com/jitsi/jitsi-meet/blob/master/doc/turn.md) and the default jitsi-meet [quick-install](https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md).

The specific prosody module mod_restturn.lua was build from the [mod_turncredentials.lua](https://github.com/otalk/mod_turncredentials) module from @fippo.

# Status
We currently only provide a module to get turn credentials from [api.geant.org](https://api.geant.org) but you could change the rest_turn_host prosody variable to connect to other TURN credential service (... and you should also change the path_url variable in mod_restturn.lua prosody module).

# Sequence diagram

<img src="https://github.com/daimoc/jitsi-meet-rest-turn-credentials/blob/master/xep-0215.svg">

# Manual configuration for a Jitsi-Meet instance
Edit your prosody VirtualHost configuration (/etc/prosody/conf.d/[servername].cfg.lua) :

 * Add  "restturn" in VirtualHost modules_enabled.
 * Add rest_turn_host=[rest turn server url] in VirtualHost
 * Add rest_turn_api_key=[your rest turn server api key] in VirtualHost
 * Add mod_prosody/mod_restturn.lua in prosofy module folder and restart prosody service.
```bash
cp  mod_prosody/mod_restturn.lua /usr/lib/prosody/modules/
service prosody restart
```
 * Enable the use of STUN/TURN [XEP-0215](https://xmpp.org/extensions/xep-0215.html) in p2p connections : set useStunTurn to true in config.p2p object in /etc/jitsi/meet/$HOSTNAME-config.js

 * (Optional) Enable the use of STUN/TURN
  [XEP-0215](https://xmpp.org/extensions/xep-0215.html) in jvb connections : set useStunTurn to true in config object in /etc/jitsi/meet/$HOSTNAME-config.js. For this option only turns server can be used for JVB connections as the JVB already handle many NAT traversal scenario.


# Installation of a running Jitsi-Meet server with TURN on Ubuntu
Run the install.sh script with :

 * jitsi-meet-host : your jitsi-meet server host name or IP
 * api-key         : you GEANT turn federation api key
```bash
sh install.sh jitsi-meet-host api-key
```

# Running Jitsi-Meet server with TURN  with Vagrant
Install Vagrant an your preferred desktop VM runner (....VirtualBox).

Edit the provided Vagrant file and change HOST and API_KEY variables and then run :

```bash
vagrant up
```

# How to test with Chrome

 * Open chrome://webrtc-internals/
 * 2 browsers in a test conference for example https://HOST/testturn
 * You should see the STUN/TURNS credential in the iceServers parameters of your Peerconnections.
 * Force relay mode in jitsi-meet configuration by adding #config.p2p.iceTransportPolicy="relay" in your jitsi conference link or by setting the p2p.iceTransportPolicy option to realy in your /etc/jitsi/meet/$HOSTNAME-config.js file.
