
# Script Bash : Synchronisation de fichiers vers un serveur distant

## Aperçu
Ce script automatise la synchronisation des fichiers de commandes d'un répertoire local vers un serveur ERP distant, avec archivage des fichiers transférés avec succès.
Il sera éxecuté que par un compte de service nommé "plutus-sync".
## Configuration

`COMMANDES_DIR` Répertoire source contenant les fichiers à synchroniser 
`ARCHIVE_DIR` Destination des fichiers traités 
`REMOTE_USER` Utilisateur SSH pour la connexion distante 
`REMOTE_HOST` Nom du serveur distant 
`REMOTE_DIR` Répertoire de destination distant 
`LOG_FILE` Fichier journal d'exécution du script 

## Fonctions

### `log()`
Enregistre les messages avec horodatage dans le fichier journal.

### `create_archive_dir()`
Crée le répertoire d'archivage s'il n'existe pas.

### `sync_files()`
- Parcourt les fichiers dans `COMMANDES_DIR`
- Transfère chaque fichier vers le serveur distant en utilisant `scp`
- En cas de succès : déplace le fichier vers le répertoire d'archivage
- En cas d'échec : enregistre l'erreur avec formatage de texte en rouge

### `main()`
Orchestre l'exécution du script de manière séquentielle.

## Utilisation dans le cron (Execution toute les 5 minutes)
Veuillez à bien ajouter le droit d'execution au script bash: 
```bash
chmod +x sync_plutus.sh
```
Ouvrez la configuration crontab pour l'utilisateur plutus-sync:
```bash
sudo crontab -u plutus-sync -e 
```
Rajouter la configuration permettant l'execution toute les 5 minutes dans le fichiers crontab:
```bash
*/5 * * * * /var/www/scripts/sync_plutus.sh 
```

## Prérequis
- Authentification SSH par clé configurée pour `plutus-erp@srv-erp-plutus`
- Permissions de lecture/écriture sur les répertoires locaux
- Permissions d'écriture sur `C:/Temp/Commandes` distant

## Journalisation
Toutes les opérations sont enregistrées dans `sync_plutus.log` avec horodatages pour audit et dépannage.

