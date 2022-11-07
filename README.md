# Ez VPN: Easy Linux CLI VPN manager for multiple providers

This tool can handle basic functionalities of several VPN apps without having to use different commands.

An official VPN CLI app is required for each VPN to control.

## Supported VPNs:
- [IVPN](https://www.ivpn.net/apps-linux/)
- [Mullvad](https://mullvad.net/en/download/linux/)
- [Expressvpn](https://www.expressvpn.com/latest#linux)
- [Nordvpn](https://nordvpn.com/download/linux/)

## Installation
```
$ git clone https://github.com/andrea-varesio/ez-vpn.git $HOME/ez-vpn
$ rm -rf $HOME/ez-vpn/.git
$ ln -s $HOME/ez-vpn/ez-vpn.sh $HOME/.local/bin/ez-vpn
```

## Usage
```
usage: ez-vpn [OPTION] [POLICY]
```

Short | Argument | Info
---|---|---
`h` | `help` | show this help message and exit
`l` | `license` | show license and exit
`v` | `version` | show current version and tested version for each supported VPN
`u` | `update` | check for new versions and update if available
` ` | `account` | show account information
`a` | `autoconnect` | set autoconnect policy [`on`/`off`]
`c` | `connect` | connect to VPN (accepts country code in `POLICY` field)
`d` | `disconnect` | disconnect
`r` | `reconnect` | force reconnect
`s` | `status` | show VPN status

## Contributions
Contributions are welcome, feel free to submit issues and/or pull requests.

### To-Do
- Expand VPN compatibilty list
- Increase available functions
- Testing

## Disclaimer
This tool is neither affiliated with, nor endorsed by any of the VPN providers in any way.

## LICENSE
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

"EZ VPN" - Easy Linux CLI VPN manager for multiple providers<br />
Copyright (C) 2022 Andrea Varesio <https://www.andreavaresio.com/><br />
Source Code: <https://github.com/andrea-varesio/ez-vpn>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a [copy of the GNU General Public License](https://github.com/andrea-varesio/ez-vpn/blob/main/LICENSE)
along with this program.  If not, see <https://www.gnu.org/licenses/>.

<div align="center">
<a href="https://github.com/andrea-varesio/ez-vpn/">
  <img src="http://hits.dwyl.com/andrea-varesio/ez-vpn.svg?style=flat-square" alt="Hit count" />
</a>
</div>