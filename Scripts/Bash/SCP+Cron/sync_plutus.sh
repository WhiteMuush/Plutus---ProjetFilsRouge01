#!/bin/bash

# Ce script synchronise les fichiers JSON vers le serveur distant via SCP, puis archive les fichiers traités localement.

# Définit le répertoire source contenant les fichiers de commandes
COMMANDES_DIR="/var/www/plutusweb/commandes"

# Définit le répertoire d archive pour les fichiers traités
ARCHIVE_DIR="/var/www/plutusweb/archives"

# Informations de connexion au serveur distant
REMOTE_USER="plutus-erp"
REMOTE_HOST="srv-erp-plutus"
REMOTE_DIR="C:/Temp/Commandes"

# Chemin du fichier de log pour suivre l execution du script
LOG_FILE="./sync_plutus.log"

# Fonction pour enregistrer les messages avec horodatage
function log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Fonction pour créer le répertoire d archive s il n'existe pas
function create_archive_dir(){
    if [ ! -d "$ARCHIVE_DIR" ]; then
        mkdir -p "$ARCHIVE_DIR"
        log "Répertoire d'archive créé: $ARCHIVE_DIR"
    fi
}

# Fonction pour parcourir les fichiers et les synchroniser vers le serveur distant
function sync_files(){
    # Parcourt tous les fichiers JSON dans le répertoire de commandes
    for file in "$COMMANDES_DIR"/*.json; do
        # Ignore si aucun fichier JSON n'est trouvé
        [ -f "$file" ] || continue

        # Récupère le nom du fichier pour les logs
        filename=$(basename "$file")

        # Enregistre la tentative de transfert
        log "Transfert du fichier: $filename"

        # Copie le fichier vers le serveur distant et gère le succès/échec
        if scp "$file" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"; then
            # Déplace le fichier vers le répertoire d'archive en cas de succès
            mv "$file" "$ARCHIVE_DIR/"
            log "Fichier transféré et archivé avec succès: $filename"
        else
            # Enregistre l erreur si le transfert échoue
            log "Erreur: Échec du transfert du fichier: $filename"
        fi
    done
}

# Fonction principale pour orchestrer l'exécution du script
function main(){
    create_archive_dir
    sync_files
}

# Exécute la fonction principale
main