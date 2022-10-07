
function DisplayMenu {
Clear-Host
Write-Host @"

          MENU POWERSHELL POUR L'ACTIVE DIRECTORY           
                                                            
 1) Importer les utilisateurs à partir du CSV               
 2) Exit                                                    


"@ -ForegroundColor black -BackgroundColor white
Write-Host "Choisir son option"
$MENU = Read-Host "option"
Import-Module ActiveDirectory
Import-Module 'Microsoft.PowerShell.Security'
Switch ($MENU)
{

1 {


$fichiercsv = Import-Csv -Delimiter ";" -Path C:\Users\Administrateur\Desktop\import.csv


do {
    $uniteorganisation = Read-Host "Rentre ton unité d'organisation"
    $adUo = Get-ADOrganizationalUnit -Filter "name -eq '$uniteorganisation'"
    if ($adUo) {
        Write-Host 'UO existe déjà'
    }
} while ($adUo)

New-ADOrganizationalUnit -Name "$uniteorganisation" -Path "DC=aboukherouba,DC=LAN" 
Write-Host 'UO' $uniteorganisation 'vient tout juste de se créer'


$chemin = "OU=$uniteorganisation,DC=aboukherouba,DC=LAN"



do {
    $groupesecurity = Read-Host "Rentre ton premier groupe de sécurité"
    $adGroup = Get-ADGroup -Filter "SamAccountName -eq '$groupesecurity'"
    if ($adGroup) {
        Write-Host 'le premier groupe existe déjà'
    }
} while ($adGroup)

New-ADGroup -Name $groupesecurity -Path $chemin -GroupCategory Security
Write-Host 'le groupe' $groupesecurity 'vient tout juste de se créer'






do {
    $groupesecurity2 = Read-Host "Rentre ton deuxième groupe de sécurité"
    $adGroup2 = Get-ADGroup -Filter "SamAccountName -eq '$groupesecurity2'"
    if ($adGroup2) {
        Write-Host 'le deuxième groupe existe déjà'
    }
} while ($adGroup2)

New-ADGroup -Name $groupesecurity2 -Path $chemin -GroupCategory Security
Write-Host 'le groupe' $groupesecurity2 'vient tout juste de se créer'


#BLOCKED


foreach ($User in $fichiercsv)
       {
              $Username    = $User.Username
              $Password    = $User.password
              $Prenom      = $User.Prenom 
              $ID          = $User.ID
              $Nom         = $User.Nom

if ( Get-ADUser -F { SamAccountName -eq $Username }) {


Write-Host 'utilisateur' $Username 'existe déjà'
}


else {

New-ADUser -SamAccountName $Username -UserPrincipalName "$Username@aboukherouba.LAN" -Name "$Prenom $Nom" -GivenName $Prenom -Surname $Nom -Enabled $true -DisplayName "$Nom, $Prenom" -Path $chemin -AccountPassword (convertto-securestring $Password -AsPlainText -Force)
Write-Host "$Username vient tout juste de se créer"
}

$userfichiercsv  = (Get-ADUser $Username).distinguishedName


If ( $ID -le 50 )  {
              Move-ADObject -Identity  $userfichiercsv   -TargetPath $chemin
              Add-ADGroupMember -Identity $groupesecurity -Members $Username
                     }
       If ( $ID -ge 50 ) {
              Move-ADObject -Identity  $userfichiercsv  -TargetPath $chemin
              Add-ADGroupMember -Identity $groupesecurity2 -Members $Username                            
                                          }

}


#ENDBLOCKED

Write-Host 'veuillez patientez afin que la console redémarre avec les changements' -ForegroundColor black -BackgroundColor white
Start-Sleep -Seconds 2




DisplayMenu
}

3 {
#OPTION3 - EXIT
Write-Host "Merci a bientot"
Start-Sleep -Seconds 2
Break
}

default {
#DEFAULT OPTION
Write-Host "Option impossible"
Start-Sleep -Seconds 2
DisplayMenu
}
}
}
DisplayMenu
