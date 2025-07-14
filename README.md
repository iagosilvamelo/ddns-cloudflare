# Script DDNS para Cloudflare em PowerShell (v2.0 com Suporte a .env)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg?style=for-the-badge&logo=powershell)

Um script simples e eficaz para Windows que atualiza automaticamente um registro DNS do tipo 'A' na Cloudflare. Esta versão utiliza um arquivo de configuração `.env` para armazenar suas credenciais de forma segura, separada do código principal.

Ideal para quem possui uma conexão de internet com IP dinâmico e precisa de um endereço de domínio estável para acessar serviços em sua rede local.

## Funcionalidades

- **Configuração Segura:** Armazena credenciais (Token de API, domínios) em um arquivo `.env`, mantendo o código do script limpo e seguro.
- **Detecção de IP Público:** Identifica automaticamente o endereço IP público da sua rede.
- **Atualização Inteligente:** Compara o IP atual com o registrado na Cloudflare e realiza a atualização somente quando há uma mudança.
- **Segurança:** Utiliza o sistema de Tokens de API da Cloudflare para acesso granular.
- **Automação Fácil:** Projetado para ser executado de forma agendada e silenciosa pelo Agendador de Tarefas do Windows.

## Pré-requisitos

1.  **Uma conta Cloudflare:** Com um domínio já configurado.
2.  **Um Registro DNS 'A':** Criado no painel da Cloudflare que será usado para o DDNS.
3.  **Um Token de API da Cloudflare:** Com permissões de `Zone:Zone:Read` e `Zone:DNS:Edit` para a zona desejada.

## Configuração

A configuração agora é feita em dois arquivos.

### 1. Crie o Arquivo `.env`

Na mesma pasta onde você salvou o script `cloudflare_ddns.ps1`, crie um arquivo chamado `.env`. Abra-o e adicione suas informações, como no exemplo abaixo:

```env
# Arquivo de configuração para o script DDNS da Cloudflare

# Cole o Token de API que você criou na Cloudflare. SEM ASPAS ""
CLOUDFLARE_API_TOKEN=SEU_TOKEN_AQUI

# O nome exato da sua Zona (seu domínio principal). SEM ASPAS ""
CLOUDFLARE_ZONE_NAME=seudominio.com

# O nome completo do registro DNS que você quer atualizar. SEM ASPAS ""
CLOUDFLARE_RECORD_NAME=casa.seudominio.com
```

### 2. Baixe o Script cloudflare_ddns.ps1
Faça o download do arquivo cloudflare_ddns.ps1 e salve-o na mesma pasta do seu arquivo .env. Nenhuma edição é necessária no arquivo do script.

## Automação com o Agendador de Tarefas

Para que o script rode automaticamente, você precisa agendar sua execução.

### 1. Permitir a Execução de Scripts

Por segurança, o Windows restringe a execução de scripts PowerShell. Execute este comando **uma única vez** para permitir:

-   Clique no Menu Iniciar, digite "PowerShell", clique com o botão direito em **Windows PowerShell** e selecione **"Executar como administrador"**.
-   Execute o comando:
    ```powershell
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    ```
-   Confirme pressionando `S` e `Enter`.

### 2. Criar a Tarefa Agendada

1.  Abra o **Agendador de Tarefas** (`taskschd.msc`).
2.  No menu "Ações", clique em **"Criar Tarefa..."**.
3.  Na aba **Geral**:
    -   **Nome:** `Atualização DDNS Cloudflare`.
    -   Marque **"Executar estando o usuário conectado ou não"**.
    -   Marque **"Executar com privilégios mais altos"**.
4.  Na aba **Disparadores**:
    -   Clique em **"Novo..."**.
    -   Configure a tarefa para ser repetida a cada **15 minutos** (ou o intervalo que desejar), por um período **indefinido**.
5.  Na aba **Ações**:
    -   Clique em **"Novo..."**.
    -   **Programa/script:** `powershell.exe`
    -   **Adicione argumentos (opcional):** Copie e cole a linha abaixo, ajustando o caminho para o local onde você salvou o script.
        ```
        -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\cloudflare_ddns.ps1"
        ```
6.  Na aba **Condições**:
    -   Desmarque a opção **"Iniciar a tarefa somente se o computador estiver em alimentação CA"** se quiser que ela rode também na bateria (em notebooks).
7.  Clique em **OK** e digite a senha do seu usuário do Windows quando solicitado.

Seu DDNS agora está configurado e será atualizado automaticamente!

## Licença

Distribuído sob a Licença MIT.