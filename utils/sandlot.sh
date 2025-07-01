#!/bin/bash
# Sandlot. Bloodhound Installer Script for Legacy and CE
# Sp3ctre4
# July 1, 2025

# The Official Install documentation are not followed here. This is a custom install solution.
#
# The docker compose file is from here:
# https://github.com/SpecterOps/BloodHound/blob/main/examples/docker-compose/docker-compose.yml
#

# Script Arguments
MODE="${1}"
HOUND="${2}"

# Print Syntax function
print_help(){
        echo "Syntax: sudo ${0} <MODE> <HOUND>"
        echo " - MODE = install/remove"
        echo " - HOUND = legacy/ce"
        echo "           - legacy is Bloodhound V4, no longer supported but OG"
        echo "           - ce is Bloodhound Community Edition, supported release."
        echo " - Sudo required for package installation (docker related)"
}

### Pre Script Checks

# Check if no args
if [[ "${#}" -ne 2 ]]; then
        print_help
        exit 1
fi

# Check for Sudo privs
if [[ "${EUID}" -ne 0 ]]; then
        echo "Error: Insufficient rights. Run with sudo."
        exit 1
fi

# Check if Args provided are the right form
if [[ "${MODE}" != "install" ]] && [[ "${MODE}" != "remove" ]]; then
        echo "Error: MODE must either be \"install\" or \"remove\""
        exit 1
elif [[ "${HOUND}" != "legacy" ]] && [[ "${HOUND}" != "ce" ]]; then
        echo "Error: HOUND must either be \"legacy\" or \"ce\""
        exit 1
fi

# Assign variables 
IS_INSTALL=0
IS_LEGACY=0
if [[ "${MODE}" == "install" ]]; then
        IS_INSTALL=1
fi
if [[ "${HOUND}" == "legacy" ]]; then
        IS_LEGACY=1
fi

### Functions

# base install features that don't depend on either version of bh
base_install(){
        if [[ ! -d "bloodhound" ]]; then
                echo "[*] Creating ./\"bloodhound\" workspace"
                mkdir "bloodhound"
        fi
}

# install bloodhound legacy
legacy_install(){
        echo "legacy"
}

# install bloodhound ce
ce_install(){
        echo "[*] Adding Docker's APT Repository to /etc/apt/sources.list.d/"
        printf '%s\n' "deb https://download.docker.com/linux/debian bookworm stable" | \
                sudo tee /etc/apt/sources.list.d/docker-ce.list 
        # replace ^bookworm with latest deb

        echo "[*] Importing Docker Keyring to /etc/apt/trusted.gpg.d/"
        curl -fsSL https://download.docker.com/linux/debian/gpg | \
                sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg

        echo "[*] Updating APT Repository"
        sudo apt update -y

        echo "[*] Installing Docker Compose Packages"
        sudo apt install docker-ce docker-ce-cli containerd.io -y

        echo "[*] Downloading Bloodhound CE's Docker Compose File"
        # this doesn't work :( wget -nv https://raw.githubusercontent.com/SpecterOps/BloodHound_CLI/refs/heads/main/docker-compose.yml && mv docker-compose.yml bloodhound/
	# This one does!
        echo """IyBDb3B5cmlnaHQgMjAyMyBTcGVjdGVyIE9wcywgSW5jLgojCiMgTGljZW5zZWQgdW5kZXIgdGhl
IEFwYWNoZSBMaWNlbnNlLCBWZXJzaW9uIDIuMAojIHlvdSBtYXkgbm90IHVzZSB0aGlzIGZpbGUg
ZXhjZXB0IGluIGNvbXBsaWFuY2Ugd2l0aCB0aGUgTGljZW5zZS4KIyBZb3UgbWF5IG9idGFpbiBh
IGNvcHkgb2YgdGhlIExpY2Vuc2UgYXQKIwojICAgICBodHRwOi8vd3d3LmFwYWNoZS5vcmcvbGlj
ZW5zZXMvTElDRU5TRS0yLjAKIwojIFVubGVzcyByZXF1aXJlZCBieSBhcHBsaWNhYmxlIGxhdyBv
ciBhZ3JlZWQgdG8gaW4gd3JpdGluZywgc29mdHdhcmUKIyBkaXN0cmlidXRlZCB1bmRlciB0aGUg
TGljZW5zZSBpcyBkaXN0cmlidXRlZCBvbiBhbiAiQVMgSVMiIEJBU0lTLAojIFdJVEhPVVQgV0FS
UkFOVElFUyBPUiBDT05ESVRJT05TIE9GIEFOWSBLSU5ELCBlaXRoZXIgZXhwcmVzcyBvciBpbXBs
aWVkLgojIFNlZSB0aGUgTGljZW5zZSBmb3IgdGhlIHNwZWNpZmljIGxhbmd1YWdlIGdvdmVybmlu
ZyBwZXJtaXNzaW9ucyBhbmQKIyBsaW1pdGF0aW9ucyB1bmRlciB0aGUgTGljZW5zZS4KIwojIFNQ
RFgtTGljZW5zZS1JZGVudGlmaWVyOiBBcGFjaGUtMi4wCgpzZXJ2aWNlczoKICBhcHAtZGI6CiAg
ICBpbWFnZTogZG9ja2VyLmlvL2xpYnJhcnkvcG9zdGdyZXM6MTYKICAgIGVudmlyb25tZW50Ogog
ICAgICAtIFBHVVNFUj0ke1BPU1RHUkVTX1VTRVI6LWJsb29kaG91bmR9CiAgICAgIC0gUE9TVEdS
RVNfVVNFUj0ke1BPU1RHUkVTX1VTRVI6LWJsb29kaG91bmR9CiAgICAgIC0gUE9TVEdSRVNfUEFT
U1dPUkQ9JHtQT1NUR1JFU19QQVNTV09SRDotYmxvb2Rob3VuZGNvbW11bml0eWVkaXRpb259CiAg
ICAgIC0gUE9TVEdSRVNfREI9JHtQT1NUR1JFU19EQjotYmxvb2Rob3VuZH0KICAgICMgRGF0YWJh
c2UgcG9ydHMgYXJlIGRpc2FibGVkIGJ5IGRlZmF1bHQuIFBsZWFzZSBjaGFuZ2UgeW91ciBkYXRh
YmFzZSBwYXNzd29yZCB0byBzb21ldGhpbmcgc2VjdXJlIGJlZm9yZSB1bmNvbW1lbnRpbmcKICAg
ICMgcG9ydHM6CiAgICAjICAgLSAxMjcuMC4wLjE6JHtQT1NUR1JFU19QT1JUOi01NDMyfTo1NDMy
CiAgICB2b2x1bWVzOgogICAgICAtIHBvc3RncmVzLWRhdGE6L3Zhci9saWIvcG9zdGdyZXNxbC9k
YXRhCiAgICBoZWFsdGhjaGVjazoKICAgICAgdGVzdDoKICAgICAgICBbCiAgICAgICAgICAiQ01E
LVNIRUxMIiwKICAgICAgICAgICJwZ19pc3JlYWR5IC1VICR7UE9TVEdSRVNfVVNFUjotYmxvb2Ro
b3VuZH0gLWQgJHtQT1NUR1JFU19EQjotYmxvb2Rob3VuZH0gLWggMTI3LjAuMC4xIC1wIDU0MzIi
CiAgICAgICAgXQogICAgICBpbnRlcnZhbDogMTBzCiAgICAgIHRpbWVvdXQ6IDVzCiAgICAgIHJl
dHJpZXM6IDUKICAgICAgc3RhcnRfcGVyaW9kOiAzMHMKCiAgZ3JhcGgtZGI6CiAgICBpbWFnZTog
ZG9ja2VyLmlvL2xpYnJhcnkvbmVvNGo6NC40LjQyCiAgICBlbnZpcm9ubWVudDoKICAgICAgLSBO
RU80Sl9BVVRIPSR7TkVPNEpfVVNFUjotbmVvNGp9LyR7TkVPNEpfU0VDUkVUOi1ibG9vZGhvdW5k
Y29tbXVuaXR5ZWRpdGlvbn0KICAgICAgLSBORU80Sl9kYm1zX2FsbG93X191cGdyYWRlPSR7TkVP
NEpfQUxMT1dfVVBHUkFERTotdHJ1ZX0KICAgICMgRGF0YWJhc2UgcG9ydHMgYXJlIGRpc2FibGVk
IGJ5IGRlZmF1bHQuIFBsZWFzZSBjaGFuZ2UgeW91ciBkYXRhYmFzZSBwYXNzd29yZCB0byBzb21l
dGhpbmcgc2VjdXJlIGJlZm9yZSB1bmNvbW1lbnRpbmcKICAgIHBvcnRzOgogICAgICAtIDEyNy4w
LjAuMToke05FTzRKX0RCX1BPUlQ6LTc2ODd9Ojc2ODcKICAgICAgLSAxMjcuMC4wLjE6JHtORU80
Sl9XRUJfUE9SVDotNzQ3NH06NzQ3NAogICAgdm9sdW1lczoKICAgICAgLSAke05FTzRKX0RBVEFf
TU9VTlQ6LW5lbzRqLWRhdGF9Oi9kYXRhCiAgICBoZWFsdGhjaGVjazoKICAgICAgdGVzdDoKICAg
ICAgICBbCiAgICAgICAgICAiQ01ELVNIRUxMIiwKICAgICAgICAgICJ3Z2V0IC1PIC9kZXYvbnVs
bCAtcSBodHRwOi8vbG9jYWxob3N0Ojc0NzQgfHwgZXhpdCAxIgogICAgICAgIF0KICAgICAgaW50
ZXJ2YWw6IDEwcwogICAgICB0aW1lb3V0OiA1cwogICAgICByZXRyaWVzOiA1CiAgICAgIHN0YXJ0
X3BlcmlvZDogMzBzCgogIGJsb29kaG91bmQ6CiAgICBpbWFnZTogZG9ja2VyLmlvL3NwZWN0ZXJv
cHMvYmxvb2Rob3VuZDoke0JMT09ESE9VTkRfVEFHOi1sYXRlc3R9CiAgICBlbnZpcm9ubWVudDoK
ICAgICAgLSBiaGVfZGlzYWJsZV9jeXBoZXJfY29tcGxleGl0eV9saW1pdD0ke2JoZV9kaXNhYmxl
X2N5cGhlcl9jb21wbGV4aXR5X2xpbWl0Oi1mYWxzZX0KICAgICAgLSBiaGVfZW5hYmxlX2N5cGhl
cl9tdXRhdGlvbnM9JHtiaGVfZW5hYmxlX2N5cGhlcl9tdXRhdGlvbnM6LWZhbHNlfQogICAgICAt
IGJoZV9ncmFwaF9xdWVyeV9tZW1vcnlfbGltaXQ9JHtiaGVfZ3JhcGhfcXVlcnlfbWVtb3J5X2xp
bWl0Oi0yfQogICAgICAtIGJoZV9kYXRhYmFzZV9jb25uZWN0aW9uPXVzZXI9JHtQT1NUR1JFU19V
U0VSOi1ibG9vZGhvdW5kfSBwYXNzd29yZD0ke1BPU1RHUkVTX1BBU1NXT1JEOi1ibG9vZGhvdW5k
Y29tbXVuaXR5ZWRpdGlvbn0gZGJuYW1lPSR7UE9TVEdSRVNfREI6LWJsb29kaG91bmR9IGhvc3Q9
YXBwLWRiCiAgICAgIC0gYmhlX25lbzRqX2Nvbm5lY3Rpb249bmVvNGo6Ly8ke05FTzRKX1VTRVI6
LW5lbzRqfToke05FTzRKX1NFQ1JFVDotYmxvb2Rob3VuZGNvbW11bml0eWVkaXRpb259QGdyYXBo
LWRiOjc2ODcvCiAgICAgIC0gYmhlX3JlY3JlYXRlX2RlZmF1bHRfYWRtaW49JHtiaGVfcmVjcmVh
dGVfZGVmYXVsdF9hZG1pbjotZmFsc2V9CiAgICAgIC0gYmhlX2dyYXBoX2RyaXZlcj0ke0dSQVBI
X0RSSVZFUjotbmVvNGp9CiAgICAgICMjIyBBZGQgYWRkaXRpb25hbCBlbnZpcm9ubWVudCB2YXJp
YWJsZXMgeW91IHdpc2ggdG8gdXNlIGhlcmUuCiAgICAgICMjIyBGb3IgY29tbW9uIGNvbmZpZ3Vy
YXRpb24gb3B0aW9ucyB0aGF0IHlvdSBtaWdodCB3YW50IHRvIHVzZSBlbnZpcm9ubWVudCB2YXJp
YWJsZXMgZm9yLCBzZWUgYC5lbnYuZXhhbXBsZWAKICAgICAgIyMjIGV4YW1wbGU6IGJoZV9kYXRh
YmFzZV9jb25uZWN0aW9uPSR7YmhlX2RhdGFiYXNlX2Nvbm5lY3Rpb259CiAgICAgICMjIyBUaGUg
bGVmdCBzaWRlIGlzIHRoZSBlbnZpcm9ubWVudCB2YXJpYWJsZSB5b3UncmUgc2V0dGluZyBmb3Ig
Ymxvb2Rob3VuZCwgdGhlIHZhcmlhYmxlIG9uIHRoZSByaWdodCBpbiBgJHt9YAogICAgICAjIyMg
aXMgdGhlIHZhcmlhYmxlIGF2YWlsYWJsZSBvdXRzaWRlIG9mIERvY2tlcgogICAgcG9ydHM6CiAg
ICAgICMjIyBEZWZhdWx0IHRvIGxvY2FsaG9zdCB0byBwcmV2ZW50IGFjY2lkZW50YWwgcHVibGlz
aGluZyBvZiB0aGUgc2VydmljZSB0byB5b3VyIG91dGVyIG5ldHdvcmtzCiAgICAgICMjIyBUaGVz
ZSBjYW4gYmUgbW9kaWZpZWQgYnkgeW91ciAuZW52IGZpbGUgb3IgYnkgc2V0dGluZyB0aGUgZW52
aXJvbm1lbnQgdmFyaWFibGVzIGluIHlvdXIgRG9ja2VyIGhvc3QgT1MKICAgICAgLSAke0JMT09E
SE9VTkRfSE9TVDotMTI3LjAuMC4xfToke0JMT09ESE9VTkRfUE9SVDotODA4MH06ODA4MAogICAg
IyMjIFVuY29tbWVudCB0byB1c2UgeW91ciBvd24gYmxvb2Rob3VuZC5jb25maWcuanNvbiB0byBj
b25maWd1cmUgdGhlIGFwcGxpY2F0aW9uCiAgICAjIHZvbHVtZXM6CiAgICAjICAgLSAuL2Jsb29k
aG91bmQuY29uZmlnLmpzb246L2Jsb29kaG91bmQuY29uZmlnLmpzb246cm8KICAgIGRlcGVuZHNf
b246CiAgICAgIGFwcC1kYjoKICAgICAgICBjb25kaXRpb246IHNlcnZpY2VfaGVhbHRoeQogICAg
ICBncmFwaC1kYjoKICAgICAgICBjb25kaXRpb246IHNlcnZpY2VfaGVhbHRoeQoKdm9sdW1lczoK
ICBuZW80ai1kYXRhOgogIHBvc3RncmVzLWRhdGE6Cg==""" > config.txt
        base64 -d config.txt > bloodhound/docker-compose.yml
        rm config.txt

        echo "[*] Starting Docker Service"
        sudo systemctl start docker
}

# base removal steps that don't depend on either version of bh
base_remove(){
        # remove bloodhound workspace dir and everything inside
        if [[ -d "bloodhound" ]]; then
                echo "[*] Removing Bloodhound Workspace (all data)"
                sudo rm -rf "bloodhound"
        fi
}

# remove bloodhound legacy
remove_legacy(){
        echo "legacy"
}

# remove bloodhound ce
remove_ce(){
        echo "[*] Stopping Docker Service"
        sudo systemctl stop docker

        echo "[*] Uninstalling Docker Compose Packages"
        sudo apt remove docker-ce docker-ce-cli containerd.io -y

        echo "[*] Removing Docker Keyring from /etc/apt/trusted.gpg.d/"
        sudo rm /etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg

        echo "[*] Removing Docker APT Repo from /etc/apt/sources.list.d/"
        sudo rm /etc/apt/sources.list.d/docker-ce.list
}

# clean up leftover dependencies
base_cleanup(){
        echo "[*] Autoremoving Leftover Dependencies"
        sudo apt autoremove -y
}


### Begin Main Body

if [[ "${IS_INSTALL}" -eq 1 ]] && [[ "${IS_LEGACY}" -eq 1 ]]; then
        echo "===== Installing Bloodhound Legacy ====="
        base_install
        legacy_install
        base_cleanup
elif [[ "${IS_INSTALL}" -eq 1 ]] && [[ "${IS_LEGACY}" -ne 1 ]]; then
        echo "===== Installing Bloodhound CE ====="
        base_install
        ce_install
        base_cleanup
        echo "===== Bloodhound CE Installed! ====="
        echo " - Inside the ./bloodhound dir is the compose file"
        echo " - run \"sudo docker compose up\" to start bloodhound ce"
        echo -e " - wait for containers to start, then copy the default password and\n  \
                go to http://localhost:8080/ with email == admin"
elif [[ "${IS_INSTALL}" -ne 1 ]] && [[ "${IS_LEGACY}" -eq 1 ]]; then
        echo "===== Removing Bloodhound Legacy ====="
        base_remove
        remove_legacy
        base_cleanup
else
        echo "===== Removing Bloodhound CE ====="
        base_remove
        remove_ce
        base_cleanup
        echo "===== Bloodhound CE Removed ====="
fi
