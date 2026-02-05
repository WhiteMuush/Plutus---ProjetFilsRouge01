

$MastersDiskPath = "C:\Hyper-V\Masters"
$OsDiskPath = "C:\Hyper-v\OSDisks"
$VSwitchName = "vSwitchName"

# Définition des fichiers de logs [Success & Errors]

### Liste de Machine virtuelles
$ListeVMs = @(
    [PSCustomObject]@{ Nom="WINSERV-01"; Master="MasterWinSrv22.vhdx" ; Disque = "OsDisk-WinSRV-01.vhdx" ; OS="Windows" ; Ram=4GB },
    [PSCustomObject]@{ Nom="UBUNTUSRV-01"; Master="MasterUbuntu.vhdx" ; Disque = "OsDisk-UbuntuSRV-01.vhdx" ; OS="Linux" ; Ram=2GB }
)

#### Etape 2 - On débute les taches du scripts
function Test-VMSwitchExist {

    param(
        [string]$SwitchName
    )

Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue | Out-Null

    if ($? -eq $false){
        write-Host "Le switch $SwitchName n'existe pas. "
        #On retourne la valeur false si le switch n'existe pas 
        return $false
    }else {
        Write-Host "Le switch $SwitchName existe déjà."
        #On retourne la valeur true si le switch existe 
        return $true
    }
}

if ((Test-VMSwitchExist -VMSwitch $VSwitchName) -eq $false){
    #si il n'existe pas alors on le crée 
    New-VMSwitch -Name $VSwitchName -SwitchType Private -ErrorAction SilentlyContinue
}

# Pour chaque élément de la liste = Pour chaque VM de la liste de VM

### Boucle = les commandes s'execteront autant fois qu'il y a de VM dans la liste
foreach ( $Machine in $ListeVMs ) {
    
    # Test / Creation du disques virtuels
    if ( (Test-Path -Path "$OsDiskPath\$($Machine.Disque)") -eq $false) {
        New-VHD -ParentPath $MastersDiskPath\$($Machine.Master) -Path $OsDiskPath\$($Machine.Disque) -Differencing
    } else {
        Write-Host "Le disque existe deja!" -ForegroundColor Yellow
    }

    # Test / Creation des Machines Virtuelles
    Get-VM -Name $Machine.Nom -ErrorAction SilentlyContinue
    if ($? -eq $false) {
        # Creation de la Machine virtuelle de Generation 2
        New-VM -Name $Machine.nom `
               -VHDPath "$OsDiskPath\$($Machine.Disque)" `
               -SwitchName $VSwitchName `
               -MemoryStartupBytes $Machine.Ram `
               -Generation 2 
    } else {
        Write-Host "La VM existe déjà!" -ForegroundColor Yellow
    }

    ##Apres creation de la VM : Si c'est une VM Linux Alors on modifie ses paramètres de sécurité
    if ($Machine.OS -eq "Linux") {
        Set-VMFirmware -VMName $Machine.Nom -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
    }

}