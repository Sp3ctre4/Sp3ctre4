#!/bin/bash
# Sandlot. Bloodhound Installer Script for Legacy and CE
# Sp3ctre4
# July 1, 2025

# The Official Install documentation are not followed here. This is a custom install solution.
#
# CE Install Guide:
# https://github.com/SpecterOps/bloodhound-docs/blob/main/docs/get-started/quickstart/community-edition-quickstart.mdx
# (Grabbed the docker-compose file from step 5, I just use that)
# Config file grabbed from:
#  https://github.com/SpecterOps/BloodHound/blob/main/examples/docker-compose/bloodhound.config.json
# (its base64 encoded down below)


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
        wget -nv https://raw.githubusercontent.com/SpecterOps/BloodHound_CLI/refs/heads/main/docker-compose.yml && mv docker-compose.yml bloodhound/

        echo "[*] Creating Bloodhound Config File at ./bloodhound/bloodhound.config.json"
        echo """ewogICJ2ZXJzaW9uIjogMSwKICAiYmluZF9hZGRyIjogIjAuMC4wLjA6ODA4MCIsCiAgIm1ldHJp
Y3NfcG9ydCI6ICI6MjExMiIsCiAgInJvb3RfdXJsIjogImh0dHA6Ly8xMjcuMC4wLjE6ODA4MC8i
LAogICJ3b3JrX2RpciI6ICIvb3B0L2Jsb29kaG91bmQvd29yayIsCiAgImxvZ19sZXZlbCI6ICJJ
TkZPIiwKICAibG9nX3BhdGgiOiAiYmxvb2Rob3VuZC5sb2ciLAogICJncmFwaF9kcml2ZXIiOiAi
bmVvNGoiLAogICJ0bHMiOiB7CiAgICAiY2VydF9maWxlIjogIiIsCiAgICAia2V5X2ZpbGUiOiAi
IgogIH0sCiAgImNvbGxlY3RvcnNfYmFzZV9wYXRoIjogIi9ldGMvYmxvb2Rob3VuZC9jb2xsZWN0
b3JzIiwKICAiZGVmYXVsdF9hZG1pbiI6IHsKICAgICJwcmluY2lwYWxfbmFtZSI6ICJhZG1pbiIs
CiAgICAiZmlyc3RfbmFtZSI6ICJCbG9vZGhvdW5kIiwKICAgICJsYXN0X25hbWUiOiAiQWRtaW4i
LAogICAgImVtYWlsX2FkZHJlc3MiOiAic3BhbUBleGFtcGxlLmNvbSIKICB9Cn0K""" > config.txt
        base64 -d config.txt > bloodhound/bloodhound.config.txt
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
