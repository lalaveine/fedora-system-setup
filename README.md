# Fedora Setup Script

Fork of the fedora-install script by tobias (https://git.furworks.de/tobias/fedora-install).

### Post-install:

- Firefox 

To enable DNS over HTTPS and Encrypted SNI in `about.config` change

```
network.trr.mode 0 -> 2
network.security.esni.enabled false -> true
```

You can check it in [here](https://www.cloudflare.com/ssl/encrypted-sni/)
