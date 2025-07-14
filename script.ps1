# =================================================================================
# Script PowerShell para atualizar um registro DNS dinâmico (DDNS) na Cloudflare
# =================================================================================

# --- CONFIGURE SUAS INFORMAÇÕES AQUI ---

# Cole o Token de API que você criou na Cloudflare.
$apiToken = "SEU_API_TOKEN_AQUI"

# O nome exato da sua Zona (seu domínio principal). Ex: "meudominio.com"
$zoneName = "seudominio.com"

# O nome completo do registro DNS que você quer atualizar. Ex: "casa.meudominio.com"
$recordName = "seu.subdominio.com"

# --- FIM DAS CONFIGURAÇÕES ---


# Cabeçalho para autenticação na API da Cloudflare
$headers = @{
    "Authorization" = "Bearer $apiToken"
    "Content-Type"  = "application/json"
}

try {
    # 1. Obter o Zone ID a partir do nome da zona
    Write-Host "Procurando Zone ID para a zona '$zoneName'..."
    $zoneResult = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones?name=$zoneName" -Method Get -Headers $headers
    $zoneId = $zoneResult.result[0].id

    if (-not $zoneId) {
        Write-Error "Zona '$zoneName' não encontrada. Verifique o nome do domínio e seu token de API."
        exit
    }
    Write-Host "Zone ID encontrado: $zoneId"

    # 2. Obter o ID e o IP atual do registro DNS na Cloudflare
    Write-Host "Buscando informações do registro DNS '$recordName'..."
    $recordResult = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?type=A&name=$recordName" -Method Get -Headers $headers
    $recordId = $recordResult.result[0].id
    $dnsIp = $recordResult.result[0].content

    if (-not $recordId) {
        Write-Error "Registro DNS '$recordName' não encontrado. Verifique se ele existe na sua zona DNS."
        exit
    }
    Write-Host "IP registrado na Cloudflare: $dnsIp"

    # 3. Obter o seu endereço IP público atual
    Write-Host "Verificando seu IP público atual..."
    $currentIp = Invoke-RestMethod -Uri "https://api.ipify.org"
    Write-Host "Seu IP público atual é: $currentIp"

    # 4. Comparar os IPs e atualizar se necessário
    if ($currentIp -eq $dnsIp) {
        Write-Host "IPs são os mesmos. Nenhuma atualização é necessária."
    }
    else {
        Write-Host "IP mudou! Atualizando o registro na Cloudflare..."

        $body = @{
            type    = "A"
            name    = $recordName
            content = $currentIp
            ttl     = 120
            proxied = $false
        } | ConvertTo-Json

        $updateResult = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$recordId" -Method Put -Headers $headers -Body $body

        if ($updateResult.success) {
            Write-Host "Sucesso! O registro DNS foi atualizado para '$currentIp'."
        }
        else {
            Write-Error "Falha ao atualizar o registro DNS. Resposta da API: $($updateResult | ConvertTo-Json -Depth 5)"
        }
    }
}
catch {
    Write-Error "Ocorreu um erro inesperado durante a execução do script."
    Write-Error $_.Exception.Message
}