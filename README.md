# jitsi-meet-rest-turn-credentials
The project is made to test the Configuration files for running a Jitsi Meet server with REST API For Access To TURN Services [draft](https://tools.ietf.org/html/draft-uberti-behave-turn-rest-00) and specialy with the [GEANT TURN FEDERATION](http://turn.geant.org/).

It's build from [jitsi-meet turn configuration documentation](https://github.com/jitsi/jitsi-meet/blob/master/doc/turn.md) and default jitsi-meet [quick-install](https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md).

# Status

We currently only provide a module du get turn credentials from api.geant.org but you could change the rest_turn_host prosody variable to connect to other TURN credential service (... and you should also change the path_url variable in mod_restturn prosody module)

## Installation on Ubuntu

Run the install.sh script with :
*  jitsi-meet-host : your jitsi-meet server host name or IP
*  api_key         ; you GEANT turn federation api_key

```bash
sh install.sh jitsi-meet-host api_key
```


## Running with Vagrant

Edit the provided Vagrant file and change HOST and API_KEY varaibles then run :

Install Vagrant an your prefered dektop VM runner (....VirtualBox).

```bash
vagrant up
```

## How to test with Chrome
* Open chrome://webrtc-internals/
* 2 browsers in a test conference for exemple https://HOST/testturn
* You should see the STUN/TURNS credential in the iceServers paramters of your Peerconnections.
