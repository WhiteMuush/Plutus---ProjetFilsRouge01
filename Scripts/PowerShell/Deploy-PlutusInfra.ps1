# Définir le chemin du fichier journal
$LogFile = ".\Deploy-PlutusInfra.log"

# Définir le chemin vers le disque Master
$MastersDiskPath = "C:\Hyper-V\Masters"

# Définir le chemin où seront stockés les disques Différenciels
$OsDiskPath = "C:\Hyper-v\OSDisks"

# Définir le nom du switch virtuel
$VSwitchName = "vSwitchName"

# Fonction pour initialiser le fichier de log
function Initialize-LogFile {
    param([string]$LogPath)
    
    if (-not (Test-Path -Path $LogPath)) {
        New-Item -Path $LogPath -ItemType File -Force | Out-Null
        Write-Host "Fichier log créé: $LogPath"
    }
}

# Fonction pour écrire les journaux avec horodatage
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "ERROR", "WARNING")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    Add-Content -Path $LogFile -Value $LogEntry
    Write-Host $LogEntry
}


# Liste des machines virtuelles
$ListeVMs = @(
    [PSCustomObject]@{ Nom="WINSERV-01"; Master="MasterWinSrv22.vhdx" ; Disque = "OsDisk-WinSRV-01.vhdx" ; OS="Windows" ; Ram=4GB },
    [PSCustomObject]@{ Nom="UBUNTUSRV-01"; Master="MasterUbuntu.vhdx" ; Disque = "OsDisk-UbuntuSRV-01.vhdx" ; OS="Linux" ; Ram=2GB }
)

Write-Log "Début du déploiement Plutus Infra" "INFO"

# Fonction pour vérifier l'existence d'un commutateur VM
function Test-VMSwitchExist {
    param([string]$SwitchName)
    
    Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue | Out-Null
    
    if ($? -eq $false){
        Write-Log "Le switch $SwitchName n'existe pas." "WARNING"
        return $false
    }else {
        Write-Log "Le switch $SwitchName existe déjà." "SUCCESS"
        return $true
    }
}

# Créer le commutateur s'il n'existe pas
if ((Test-VMSwitchExist -SwitchName $VSwitchName) -eq $false){
    Write-Log "Création du switch $VSwitchName" "INFO"
    New-VMSwitch -Name $VSwitchName -SwitchType Private -ErrorAction SilentlyContinue
}

# Boucle de traitement pour chaque machine virtuelle
foreach ( $Machine in $ListeVMs ) {
    
    Write-Log "Traitement de la VM: $($Machine.Nom)" "INFO"
    
    # Créer le disque s'il n'existe pas
    if ( (Test-Path -Path "$OsDiskPath\$($Machine.Disque)") -eq $false) {
        Write-Log "Création du disque: $($Machine.Disque)" "INFO"
        New-VHD -ParentPath $MastersDiskPath\$($Machine.Master) -Path $OsDiskPath\$($Machine.Disque) -Differencing
    } else {
        Write-Log "Le disque existe déjà: $($Machine.Disque)" "WARNING"
    }

    # Créer la VM si elle n'existe pas
    Get-VM -Name $Machine.Nom -ErrorAction SilentlyContinue
    if ($? -eq $false) {
        Write-Log "Création de la VM: $($Machine.Nom)" "INFO"
        New-VM -Name $Machine.nom `
               -VHDPath "$OsDiskPath\$($Machine.Disque)" `
               -SwitchName $VSwitchName `
               -MemoryStartupBytes $Machine.Ram `
               -Generation 2 
        Write-Log "VM $($Machine.Nom) créée avec succès." "SUCCESS"
    } else {
        Write-Log "La VM existe déjà: $($Machine.Nom)" "WARNING"
    }

    # Configurer le firmware pour Linux
    if ($Machine.OS -eq "Linux") {
        Write-Log "Configuration du firmware Linux pour: $($Machine.Nom)" "INFO"
        Set-VMFirmware -VMName $Machine.Nom -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
    }
}

Write-Log "Fin du déploiement Plutus Infra" "SUCCESS"