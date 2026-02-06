# Script de Déploiement de VMs Hyper-V

## Description
Script PowerShell pour déployer automatiquement des VMs Windows et Linux à partir de disques Master.

## Prérequis
- Windows avec Hyper-V activé
- Droits Administrateur
- Disques Master dans `C:\Hyper-V\Masters\`

## Installation

Créer les dossiers requis :

```powershell
New-Item -Path "C:\Hyper-V\Masters" -ItemType Directory -Force
New-Item -Path "C:\Hyper-V\OSDisks" -ItemType Directory -Force
```

Placer les disques Master dans `C:\Hyper-V\Masters\` selon la configuration.

## Attention - Script non signé

Avant de lancer le script, vous devez autoriser son exécution. Par défaut, PowerShell bloque les scripts non signés.

Exécutez cette commande en tant qu'Administrateur pour autoriser l'exécution :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Utilisation

1. Exécuter en tant qu'Administrateur
2. Configurer la liste des VMs (voir section Configuration)
3. Lancer le script :

```powershell
.\DeployVMs.ps1
```

**Note :** Cette configuration n'affecte que votre utilisateur actuel.



## Configuration

Modifiez la liste des VMs dans le script :

```powershell
$ListeVMs = @(
    [PSCustomObject]@{ 
        Nom    = "WINSERV-01"
        Master = "MasterWinSrv22.vhdx"
        Disque = "OsDisk-WinSRV-01.vhdx"
        OS     = "Windows"
        Ram    = 4GB
    }
)
```

## Commandes utiles

`Start-VM -Name "NomDeLaVM"` Démarrer une VM 
`Stop-VM -Name "NomDeLaVM"` Arrêter une VM 
`Get-VM` Lister les VM
