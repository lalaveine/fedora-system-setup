# Fedora Setup Script

Fork of the fedora-install script by tobias (https://git.furworks.de/tobias/fedora-install).

### Post-install:

- Firefox 

To enable DNS over HTTPS and Encrypted SNI in `about.config` change

```
network.trr.mode 0 -> 2
network.security.esni.enabled false -> true
```

#### Optional

You can change DNS Server to cloudflare. To do that in GNOME:

1. Open Wi-Fi Settings

2. Open connection config window

3. Go to IPv4

4. Uncheck Automatic and put `1.1.1.1` in the bar

5. Click Apply

You can check if it's working in [here](https://www.cloudflare.com/ssl/encrypted-sni/)
