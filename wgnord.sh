#!/bin/sh
alias query="curl -s -H 'User-Agent: NordApp Linux 3.10.0 Linux 5.4.0-58-generic'"
login() {
	echo "Logging in..."
	jq -njc "{username: \"$1\", password: \"$2\"}" > /usr/share/wgnord/account.json
	get_token
	get_credentials
}
get_token() {
	echo "Getting new access token..."
	query 'https://zwyr157wwiu6eior.com/v1/users/tokens' -d "$(cat /usr/share/wgnord/account.json)" -H "Content-Type: application/json" > /usr/share/wgnord/token.json
}
get_credentials() {
	echo "Getting server credentials..."
	token_date=$(date -d "$(cat /usr/share/wgnord/token.json | jq -r '.expires_at')" --utc +%s)
	current_date=$(date --utc +%s)
	[ $current_date -ge $((token_date-60)) ] && get_token
	auth_token="$(echo -n "token:$(jq -j '.token' /usr/share/wgnord/token.json)" | base64 -w 0)"
	query 'https://zwyr157wwiu6eior.com/v1/users/services/credentials' -H "Content-Type: application/json" -H "Authorization: Basic $auth_token" > /usr/share/wgnord/credentials.json
}
connect() {
	is_connected && disconnect
	# get_credentials
	country_code="$(cat countries.txt | grep -i "$1" -m 1 | cut -d "	" -f 2)"
	echo "Finding best server..."
	insights="$(query "https://zwyr157wwiu6eior.com/v1/helpers/ips/insights")"
	longitude="$(echo "$insights" | jq -j '.longitude')"
	latitude="$(echo "$insights" | jq -j '.latitude')"
	recommendations="$(query "https://zwyr157wwiu6eior.com/v1/servers/recommendations?limit=20&filters%5Bservers.status%5D=online&filters%5Bservers_technologies%5D=35&filters%5Bservers_technologies%5D%5Bpivot%5D%5Bstatus%5D=online&fields%5Bservers.id%5D&fields%5Bservers.name%5D&fields%5Bservers.hostname%5D&fields%5Bservers.station%5D&fields%5Bservers.status%5D&fields%5Bservers.load%5D&fields%5Bservers.created_at%5D&fields%5Bservers.groups.id%5D&fields%5Bservers.groups.title%5D&fields%5Bservers.technologies.id%5D&fields%5Bservers.technologies.metadata%5D&fields%5Bservers.technologies.pivot.status%5D&fields%5Bservers.specifications.identifier%5D&fields%5Bservers.specifications.values.value%5D&fields%5Bservers.locations.country.name%5D&fields%5Bservers.locations.country.code%5D&fields%5Bservers.locations.country.city.name%5D&fields%5Bservers.locations.country.city.latitude%5D&fields%5Bservers.locations.country.city.longitude%5D&coordinates%5Blongitude%5D=$longitude&coordinates%5Blatitude%5D=$latitude&fields%5Bservers.ips%5D&filters%5Bcountry_id%5D=$country_code")"
	server_name="$(echo "$recommendations" | jq -j '.[0] | .name')"
	server_hostname="$(echo "$recommendations" | jq -j '.[0] | .hostname')"
	echo "Connecting to $server_hostname ($server_name)..."
	server_ip="$(echo "$recommendations" | jq -j '.[0] | .ips[0].ip.ip')"
	server_pubkey="$(echo "$recommendations" | jq -j '.[0] | .technologies[-1].metadata[0].value')"
	privkey="$(jq -j '.nordlynx_private_key' /usr/share/wgnord/credentials.json)"
	sed -e "s|PRIVKEY|$privkey|" -e "s|SERVER_PUBKEY|$server_pubkey|" -e "s|SERVER_IP|$server_ip|" /usr/share/wgnord/template.conf > /etc/wireguard/wgnord.conf
	wg-quick up wgnord && echo "Connected successfully!"
}
disconnect() {
	echo "Disconnecting..."
	wg-quick down wgnord
}
is_connected() {
	ip link show wgnord &> /dev/null
	return
}

case $1 in
	l|login) login "$2" "$3" ;;
	c|connect) connect "$2" ;;
	d|disconnect) disconnect ;;
esac
