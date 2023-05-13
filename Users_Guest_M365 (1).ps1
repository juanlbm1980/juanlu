Write-Host ""
Write-Host "[*]Obteniendo lista de objectId de grupos que empiecen por M365, espere ... "
Write-Host " "
Write-Host "[+]En caso de error --> Connect-AzureAD"
Write-Host " "

(Get-AzureADGroup -Filter "startswith(DisplayName, 'M365')" | Select-Object -ExpandProperty ObjectId) | Select-Object -Skip 1 | Out-File -FilePath lista.txt

Write-Host ""
Write-Host "[*]Obteniendo los usuarios invitados en cada uno de los grupos M365, espere, este proceso tardará unos minutos ... "
Write-Host ""

Get-Content lista.txt | ForEach-Object {
    $groupId = $_
    Get-AzureADGroupMember -ObjectId $groupId | ForEach-Object {
        try {
            Get-AzureADUser -ObjectId $_.ObjectId | Select-Object DisplayName, UserType
        } catch {
            Write-Host "Error al obtener el usuario con ObjectId $($_.ObjectId): $($_.Exception.Message)"
        }
    }
} | Out-File -FilePath users.txt

Write-Host "[*]Usuarios invitados o guest obtenidos:"
Write-Host ""

if (Select-String -Path users.txt -Pattern "invitado" -Quiet) {
    Write-Host "Hay usuarios con el userType 'invitado'"
    Select-String -Path users.txt -Pattern "invitado"
} else {
    Write-Host "No hay usuarios con el userType 'invitado'"
}

if (Select-String -Path users.txt -Pattern "guest" -Quiet) {
    Write-Host "Hay usuarios con el userType 'guest'"
    Select-String -Path users.txt -Pattern "guest"
} else {
    Write-Host "No hay usuarios con el userType 'guest'"
}

Write-Host "[*]Completado con éxito."
Write-Host ""
