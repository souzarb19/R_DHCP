# Solicita ao operador o DHCP server, Scope ID e caminho do arquivo de texto
$DHCPserver = Read-Host "Digite o nome do servidor DHCP"
$ScopeID = Read-Host "Digite o Scope ID (Exemplo: 10.113.62.0)"
$TXTFile = Read-Host "Digite o caminho completo do arquivo de texto"

# Verificar se o arquivo de texto existe
if (-not (Test-Path -Path $TXTFile)) {
    Write-Host "O arquivo de texto especificado não foi encontrado."
    exit
}

# Função para criar reserva DHCP
function CriarReservaDHCP($HostName, $IPAddress, $MACAddress) {
    $existeReserva = Get-DhcpServerv4Reservation -ComputerName $DHCPserver -ScopeId $ScopeID | Where-Object { $_.IPAddress -eq $IPAddress }

    if ($existeReserva -ne $null) {
        Write-Host "Já existe uma reserva de IP para o endereço $IPAddress."
    } else {
        Add-DhcpServerv4Reservation -ComputerName $DHCPserver -ScopeId $ScopeID -IPAddress $IPAddress -ClientId $MACAddress -Name $HostName -Type Both
        Write-Host "Reserva de IP criada com sucesso para $HostName ($IPAddress) com endereço MAC $MACAddress."
    }
}

# Ler o arquivo de texto e criar reservas DHCP para cada linha
Get-Content $TXTFile | ForEach-Object {
    $dados = $_ -split ';'  # Divide cada linha usando ';' como delimitador
    if ($dados.Count -eq 3) {
        $HostName = $dados[0].Trim()
        $IPAddress = $dados[1].Trim()
        $MACAddress = $dados[2].Trim()
        CriarReservaDHCP $HostName $IPAddress $MACAddress
    }
}
