# wgnord
This script lets you connect to NordVPN servers through WireGuard using their "NordLynx" protocol.

```
Usage: wgnord [ l(ogin) | c(onnect) | d(isconnect) | g(et_credentials) ]

login:
    wgnord l "john.smith@example.com" "verysecurepassword"
    If the password was omitted it will be read from stdin
connect:
    wgnord c france
    -f            Refresh cached longitude/latitude
    -n            Don't connect
    -o out.conf   Write config to different file
disconnect:
    wgnord d
get_credentials:
    wgnord g
    This typically isn't needed. You can try running this if the connection fails

wgnord's files are in /var/lib/wgnord, edit template.conf to change Wireguard options
```

## Installation

Dependencies: 

- jq
- curl
- wg-quick (wireguard-tools)
- openresolv (for dns)

To install them on Arch:
```
sudo pacman -S --needed jq curl wireguard-tools openresolv
```

Manual installation:
```
git clone https://github.com/phirecc/wgnord
cd wgnord
sudo install -Dm600 template.conf /var/lib/wgnord/template.conf
sudo install -Dm755 wgnord /usr/bin/wgnord
```

`wgnord` can also be installed through the AUR like so:
```
paru -S wgnord
```

## Usage
Login (you only need to do this once):
```
sudo wgnord l "bob@smith.com" "securepassword123"
```

Now you can connect to a server:
```
sudo wgnord c France
```

Note: country names are case-insensitive and grepped for, so `sudo wgnord c fra` would work aswell. See `countries.txt` for a list of available countries.

To disconnect:
```
sudo wgnord d
```

If you want to change WireGuard config parameters (MTU, DNS, etc.), simply modify `/var/lib/wgnord/template.conf`.

## Extra
This script includes a "kill-switch" because of the way wg-quick works. Connections will typically stay alive for multiple days, but if it dies you can reconnect by running another connect command.

From time to time (weekly or so) NordVPN invalidates server credentials, which causes connections to fail. Run `sudo wgnord get_credentials` to load new ones.

## Note
This third-party project is in no way affiliated with NordVPN.
