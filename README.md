# wgnord
*Note: I don't condone using NordVPN, it is untrustworthy like all other commercial VPN providers. I don't say no to free things though.*

This script lets you connect to NordVPN servers through WireGuard using their "NordLynx" protocol.

Dependencies: 

- jq
- curl
- wg-quick (wireguard-tools)

To install them on arch:
```
sudo pacman -S --needed jq curl wireguard-tools
```

## Installation
```
git clone https://git.phire.cc/me/wgnord
cd wgnord
sudo ./install.sh
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

The hardcoded sketchy-looking domain `zwyr157wwiu6eior.com` is one of the many domains NordVPN uses for its backend. Presumably to bypass some sorts of bans.

You don't have to trust me though:
```
strings /bin/nordvpnd | grep "zwyr157wwiu6eior\.com" --color
```
