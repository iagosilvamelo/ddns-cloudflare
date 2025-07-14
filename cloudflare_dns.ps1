# =================================================================================
# Script PowerShell para atualizar DDNS na Cloudflare (lendo de um arquivo .env)
# =================================================================================

# --- Carregador de Variáveis do Arquivo .env ---
try {
    # Pega o caminho do diretório onde o script está localizado
    $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    $envFilePath = Join-Path $scriptPath ".env"

    if (-not (Test-Path $envFilePath)) {
        throw "Arquivo de configuração .env não encontrado no diretório do script!"
    }

    # Lê o arquivo .env linha por linha e define as variáveis
    Get-Content $envFilePath | ForEach-Object {
        $line = $_.Trim()
        # Ignora linhas em branco e comentários
        if ($line -and $line -notmatch "^\s*#") {
            $parts = $line.Split("=", 2)
            if ($parts.Length -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()
                Set-Variable -Name $key -Value $value -Scope Script
            }
        }
    }
}
catch {
    Write-Error "Erro ao carregar o arquivo .env: $($_.Exception.Message)"
    exit # Encerra o script se não conseguir carregar as configurações
}
# --- Fim do Carregador .env ---


# As variáveis agora são carregadas do arquivo .env. O script principal começa aqui.
$apiToken = $CLOUDFLARE_API_TOKEN
$zoneName = $CLOUDFLARE_ZONE_NAME
$recordName = $CLOUDFLARE_RECORD_NAME


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
        Write-Error "Zona '$zoneName' não encontrada. Verifique o nome do domínio no arquivo .env e seu token de API."
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