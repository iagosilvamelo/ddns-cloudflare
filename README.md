# Script DDNS para Cloudflare em PowerShell

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg?style=for-the-badge&logo=powershell)

Um script simples e eficaz para Windows que atualiza automaticamente um registro DNS do tipo 'A' na Cloudflare, funcionando como um cliente de DNS Dinâmico (DDNS). Ideal para quem possui uma conexão de internet com IP dinâmico e precisa de um endereço de domínio estável para acessar serviços em sua rede local (como servidores, câmeras ou acesso remoto).

## Funcionalidades

- **Detecção de IP Público:** Identifica automaticamente o endereço IP público atual da sua rede.
- **Atualização Inteligente:** Compara o IP atual com o registrado na Cloudflare e realiza a atualização somente quando há uma mudança, evitando chamadas desnecessárias à API.
- **Segurança:** Utiliza o sistema de Tokens de API da Cloudflare, permitindo permissões de acesso granulares e seguras.
- **Automação Fácil:** Projetado para ser executado de forma agendada e silenciosa pelo Agendador de Tarefas do Windows.

## Pré-requisitos

Antes de começar, você precisará de:

1.  **Uma conta Cloudflare:** Com um domínio já configurado e ativo.
2.  **Um Registro DNS 'A':** Criado no painel da Cloudflare que será usado para o DDNS (ex: `remoto.seudominio.com`).
    -   *Dica:* Configure o TTL (Time-to-Live) deste registro para um valor baixo (como 2 minutos) para que as atualizações de IP se propaguem mais rapidamente.
3.  **Um Token de API da Cloudflare:** Crie um Token de API customizado com as seguintes permissões:
    -   `Zone` > `Zone` > `Read`
    -   `Zone` > `DNS` > `Edit`
    - Configure o token para ter acesso apenas à zona (domínio) que você deseja atualizar. **Copie e guarde este token em segurança.**

## Configuração do Script

Siga estes passos para configurar o script:

1.  **Baixe o script** `cloudflare_ddns.ps1` para uma pasta em seu computador (ex: `C:\Scripts`).
2.  **Abra o arquivo** `cloudflare_ddns.ps1` com um editor de texto como o Bloco de Notas, Notepad++ ou Visual Studio Code.
3.  **Localize a seção de configuração** no topo do arquivo e preencha suas informações:

    ```powershell
    # --- CONFIGURE SUAS INFORMAÇÕES AQUI ---

    # Cole o Token de API que você criou na Cloudflare.
    $apiToken = "SEU_API_TOKEN_AQUI"

    # O nome exato da sua Zona (seu domínio principal). Ex: "meudominio.com"
    $zoneName = "seudominio.com"

    # O nome completo do registro DNS que você quer atualizar. Ex: "remoto.seudominio.com"
    $recordName = "remoto.seudominio.com"

    # --- FIM DAS CONFIGURAÇÕES ---
    ```

4.  **Salve** o arquivo após fazer as alterações.

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