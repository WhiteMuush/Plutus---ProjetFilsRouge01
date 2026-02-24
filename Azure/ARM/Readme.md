
# Azure ARM Template - Guide d'utilisation

## Vue d'ensemble

Ce template ARM déploie une infrastructure réseau et deux machines virtuelles (Windows Server 2022 et Ubuntu 24.04) dans Azure avec une configuration de sécurité basique.

## Architecture

<img width="1562" height="1446" alt="SchemaAzure drawio" src="https://github.com/user-attachments/assets/f25e0608-8a81-4c3a-8dae-b3dd943011c9" />

## Ressources déployées

### Virtual Network
- **Nom** : `vSwitchPrivate`
- **Plage CIDR** : 192.168.10.0/24

### Interfaces Réseau
- **Windows** : `AdresseReseauWin` (192.168.10.20)
- **Linux** : `AdresseReseauLinux` (192.168.10.10)

### Machines Virtuelles
- **Windows** : `WINSERV-01` (Standard_DS1_v2)
- **Linux** : `UBUNTUSRV-01` (Standard_DS1_v2)

### Sécurité Réseau
- **NSG** : `nsg-ssh`
- **Règle SSH** : Port 22 activé


## Prérequis

- Compte Azure actif
- Azure CLI ou Azure Portal
- Resource Group créé

## Utilisation

### 1. Via Azure CLI

```bash
az deployment group create \
    --name "deployment-infratest" \
    --resource-group "votre-rg" \
    --template-file "template.json" \
    --parameters vmNameWin="WINSERV-01" vmNameLinux="UBUNTUSRV-01"
```

### 2. Via Azure Portal

1. Aller à **Resource Group** → **Déployer un modèle personnalisé**
2. Charger `template.json`
3. Ajuster les paramètres si nécessaire

## Points importants

⚠️ **Sécurité** : Les identifiants sont codés en dur (`KeyVaultSecret`). Utilisez **Azure Key Vault** en production.

⚠️ **NSG** : La règle SSH ne couvre que la communication 192.168.10.20 → 192.168.10.10. Adaptez selon vos besoins.
