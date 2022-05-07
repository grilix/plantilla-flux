# Configuración de cluster

## 0. Requerimientos

- flux2 - https://github.com/fluxcd/flux2
- Cluster kubernetes
- gnupg - https://www.gnupg.org/
- SOPS - https://github.com/mozilla/sops

## 1. SOPS

Darle a `./scripts/sops-setup.sh` para crear la configuración necesaria.

### Secretos

Cuando quieras encriptar o desencriptar secretos, usa, por ejemplo:

```
./scripts/sops.sh -e --in-place config/production/cluster-secrets.sops.yaml
./scripts/sops.sh -d --in-place config/production/cluster-secrets.sops.yaml
```

El script usará las claves de este repo.


## 2. Flux

Guarda el token de github en un archivo llamado '.gh-token', luego
corre el script de inicialización:

```
./scripts/bootstrap.sh
```
