#!/bin/bash

VERSION="20230102.01"

show_license () {
    # Print license

    echo '
    "EZ VPN" - Easy Linux CLI VPN manager for multiple providers
    Copyright (C) 2023 Andrea Varesio <https://www.andreavaresio.com/>
    Source Code: <https://github.com/andrea-varesio/ez-vpn>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    '
}

show_help () {
    # Show help message and exit

    echo '"EZ VPN" - Easy Linux CLI VPN manager for multiple providers'
    echo "Copyright (C) 2023 Andrea Varesio <https://www.andreavaresio.com/>"
    echo "version: $VERSION"
    echo
    echo 'usage: ez-vpn [OPTION] [POLICY]

    options:
    h, help         show this help message and exit
    l, license      show license and exit
    v, version      show current version and tested version for each supported VPN
    u, update       check for new versions and update if available

       account      show account information
    a, autoconnect  set autoconnect policy [on/off]
    c, connect      connect to VPN (accepts country code in POLICY field)
    d, disconnect   disconnect from VPN
    r, reconnect    force reconnect
    s, status       show VPN status
    '

    if [[ -n "$1" ]]; then exit 0; else exit 1; fi
}

show_version () {
    # Show current version and tested version for each supported VPN

    echo "EZ VPN version: $VERSION"
    echo 'Supported VPNs:
    ivpn:       3.9.43
    mullvad:    2022.5
    expressvpn: 3.34.1.0 (untested)
    nordvpn:    3.15.0 (untested)
    '
}

run_updater () {
    # Check for new versions and update

    abort_update () {
        # Print $1 error, remove temp file and exit with error 1
        echo "$1 Aborting."
        rm -rf "$temp_file"
        exit 1
    }

    ## Define command to use
    if type curl &> /dev/null; then download_cmd="curl --tlsv1.3 --proto =https -so"
    elif type wget &> /dev/null; then download_cmd="wget --secure-protocol=TLSv1_3 --https-only -q -O"
    else
        echo "Missing required dependency! (curl/wget)"
        echo "Cannot proceed with update."
        exit 1
    fi

    ## Download latest version to a temporary file and check for download errors
    temp_file="$(mktemp)"
    url="https://raw.githubusercontent.com/andrea-varesio/ez-vpn/main/ez-vpn.sh"

    if ! $download_cmd "$temp_file" $url || [[ -z $(cat "$temp_file") || $(cat "$temp_file") == "404: Not Found" ]]; then
        abort_update "Error while downloading update."
    fi

    ## Compare versions and perform update
    installed_version=$(grep -m1 VERSION "$0" | grep -o '[0-9.]*')
    downloaded_version=$(grep -m1 VERSION "$temp_file" | grep -o '[0-9.]*')

    if [[ -z "$downloaded_version" ]]; then abort_update "Error while establishing new version."; fi

    if [[ "$installed_version" == "$downloaded_version" ]]; then
        echo "Latest version ($installed_version) already installed. Update not necessary."
    else
        echo "Installed version:    $installed_version"
        echo "Latest version:       $downloaded_version"
        echo "Do you want to proceed with the update? [y/N]"
        read -r -p "> " update_prompt
        if [[ "$update_prompt" == "y" ]]; then
            cat "$temp_file" > "$0"
            updated_version=$(grep -m1 VERSION "$0" | grep -o '[0-9.]*')
                if [[ "$updated_version" == "$downloaded_version" ]]; then
                    echo "Update completed successfully: $installed_version > $downloaded_version"
                else
                    abort_update "Update could not be completed."
                fi
        else
            echo "Aborting."
        fi
    fi

    rm -rf "$temp_file"
}

run_checks () {
    # Run necessary checks

    try_vpn () {
        # Check if a VPN application is installed
        if type "$1" &> /dev/null; then ((i++)); vpn="$1"; fi
    }

    try_vpn "ivpn"
    try_vpn "mullvad"
    try_vpn "nordvpn"

    if [[ $i == 0 ]]; then
        echo "No VPN detected! Aborting."
        exit 1
    elif [[ $i -gt 1 ]]; then
        echo "Multiple VPNs detected!"
            echo "Select which VPN to use or exit program (enter a number):"
            echo "0. Exit"
            echo "1. IVPN"
            echo "2. Mullvad"
            echo "3. Nordvpn"
            echo

        for (( ; ; )); do
            read -r -p "> " vpn_no
            if [[ "$vpn_no" =~ ^[0-9]+$ ]]; then
                if [[ "$vpn_no" == 0 ]]; then exit 0; break
                elif [[ "$vpn_no" == 1 ]]; then vpn="ivpn"; break
                elif [[ "$vpn_no" == 2 ]]; then vpn="mullvad"; break
                elif [[ "$vpn_no" == 3 ]]; then vpn="nordvpn"; break
                else echo "Selected number is invalid."
                fi
            else echo "Input must be a valid number."
            fi
        done
    fi

    if [[ "$1" == "a" || "$1" == "autoconnect" ]] && [[ -z "$2" ]]; then echo "Missing policy! [on/off]"; exit 1; fi
    if [[ "$1" == "a" || "$1" == "autoconnect" ]] && [[ "$2" != "on" && "$2" != "off" ]]; then echo "Invalid policy! [on/off]"; exit 1; fi
}

exit_unsupported () {
    # Call this function when an action is not (yet) supported

    echo "Action currently not supported for $vpn"; exit 1
}

ez_ivpn () {
    # Perform action requested with $1 and additional parameter $2 (if provided)

    if [[ "$1" == "acc" ]]; then ivpn account
    elif [[ "$1" == "a" ]]; then exit_unsupported
    elif [[ "$1" == "c" ]]; then ivpn connect -any -cc "$2"
    elif [[ "$1" == "d" ]]; then ivpn disconnect
    elif [[ "$1" == "r" ]]; then ivpn disconnect &> /dev/null; sleep 1; ivpn connect -last
    elif [[ "$1" == "s" ]]; then ivpn status
    fi
}

ez_mullvad () {
    # Perform action requested with $1 and additional parameter $2 (if provided)

    if [[ "$1" == "acc" ]]; then mullvad account get
    elif [[ "$1" == "a" ]]; then mullvad auto-connect set
    elif [[ "$1" == "c" ]] && [[ -n "$2" ]]; then mullvad relay set location "$2" &> /dev/null; ez_mullvad "r"
    elif [[ "$1" == "c" ]]; then mullvad connect
    elif [[ "$1" == "d" ]]; then mullvad disconnect
    elif [[ "$1" == "r" ]]; then mullvad connect; sleep 1; mullvad reconnect
    elif [[ "$1" == "s" ]]; then mullvad status
    fi
}

ez_expressvpn () {
    # Perform action requested with $1 and additional parameter $2 (if provided)

    if [[ "$1" == "acc" ]]; then exit_unsupported
    elif [[ "$1" == "a" && "$2" == "on" ]]; then expressvpn autoconnect true
    elif [[ "$1" == "a" && "$2" == "off" ]]; then expressvpn autoconnect false
    elif [[ "$1" == "c" ]]; then expressvpn connect "$2"
    elif [[ "$1" == "d" ]]; then expressvpn disconnect
    elif [[ "$1" == "r" ]]; then expressvpn disconnect; sleep 1; expressvpn connect
    elif [[ "$1" == "s" ]]; then expressvpn status
    fi
}

ez_nordvpn () {
    # Perform action requested with $1 and additional parameter $2 (if provided)

    if [[ "$1" == "acc" ]]; then nordvpn account
    elif [[ "$1" == "a" ]]; then nordvpn set autoconnect on
    elif [[ "$1" == "c" ]]; then nordvpn c "$2"
    elif [[ "$1" == "d" ]]; then nordvpn d
    elif [[ "$1" == "r" ]]; then nordvpn d; sleep 1; nordvpn c
    elif [[ "$1" == "s" ]]; then nordvpn status
    fi
}

main () {
    # Main function

    ## Resolve program-related arguments
    if [[ "$1" == "h" || "$1" == "help" || -z "$1" ]]; then show_help "$1"; fi
    if [[ "$1" == "l" || "$1" == "license" ]]; then show_license; exit 0; fi
    if [[ "$1" == "v" || "$1" == "version" ]]; then show_version; exit 0; fi
    if [[ "$1" == "u" || "$1" == "update" ]]; then run_updater; exit 0; fi

    ## Resolve VPN-related arguments
    if [[ "$1" == "account" ]]; then comm="acc"
    elif [[ "$1" == "a" || "$1" == "autoconnect" ]]; then comm="a"
    elif [[ "$1" == "c" || "$1" == "connect" ]]; then comm="c"
    elif [[ "$1" == "d" || "$1" == "disconnect" ]]; then comm="d"
    elif [[ "$1" == "r" || "$1" == "reconnect" || -z "$1" ]]; then comm="r"
    elif [[ "$1" == "s" || "$1" == "status" || -z "$1" ]]; then comm="s"
    else printf "Invalid argument!\n\n"; show_help; exit 1
    fi

    ## Perform necessary checks and run requested action
    run_checks "$@"
    ez_$vpn $comm "$2"
}

main "$@"