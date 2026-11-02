#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
boot="$root/buildroot/board/tcrpfriend/rootfs-overlay/root/boot.sh"
tmp=$(mktemp -d)
trap 'rm -r -- "$tmp"' EXIT
cd "$tmp"

# Load only the network functions; sourcing all of boot.sh would start Friend.
for name in _cidr_to_netmask configured_ipsettings_count buildStaticNetworkCmdline setnetwork; do
    # shellcheck disable=SC1090
    source <(sed -n "/^function ${name}() {/,/^}/p" "$boot")
done
migrate_ipsettings_schema() { :; }
msgwarning() { printf '%s' "$*" >&2; }
fixture=
jq() {
    local args=("$@") last
    last=$((${#args[@]} - 1))
    args[last]="$fixture"
    command jq "${args[@]}"
}

command jq -n '{ipsettings:[{ipset:"",ipiface:"",ipaddr:"",ipgw:"",primary:true}],netdns:{ipdns:""},netproxy:{ipproxy:""}}' > "$tmp/default.json"
fixture="$tmp/default.json"
[[ $(configured_ipsettings_count) == 0 ]]
[[ -z $(buildStaticNetworkCmdline 2>"$tmp/warnings") ]]
[[ ! -s "$tmp/warnings" ]]
setnetwork > "$tmp/output"
grep -q 'staying on DHCP' "$tmp/output"
if grep -q 'Invalid static IP' "$tmp/output"; then
    echo 'Default scaffold produced a static-IP error' >&2
    exit 1
fi

command jq -n '{ipsettings:[{ipset:"",ipiface:"",ipaddr:"",ipgw:"",primary:true},{ipset:"static",ipiface:"eth0",ipaddr:"192.168.1.20/24",ipgw:"192.168.1.1",primary:true}],extra_cmdline:{mac1:"001122334455"},netdns:{ipdns:"1.1.1.1"}}' > "$tmp/mixed.json"
fixture="$tmp/mixed.json"
[[ $(configured_ipsettings_count) == 1 ]]
[[ $(buildStaticNetworkCmdline 2>"$tmp/warnings") == 'network.001122334455=192.168.1.20/255.255.255.0/192.168.1.1/1.1.1.1' ]]
[[ ! -s "$tmp/warnings" ]]

command jq -n '{ipsettings:[{ipset:"static",ipiface:"",ipaddr:"",ipgw:"",primary:true}]}' > "$tmp/partial.json"
fixture="$tmp/partial.json"
[[ $(configured_ipsettings_count) == 1 ]]
[[ -z $(buildStaticNetworkCmdline 2>"$tmp/warnings") ]]
grep -q 'invalid ipsettings entry' "$tmp/warnings"

echo 'Empty ipsettings scaffold, mixed static entry, and incomplete entry tests passed.'
