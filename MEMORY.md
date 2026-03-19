

### Resolução de Problema: Navegação na Internet / Erro "Missing X server or $DISPLAY"

**Data:** 2026-03-18

**Problema:**
Após a atualização do OpenClaw (para 2026.3.13) e a instalação do plugin `lossless-claw`, o OpenClaw perdeu a capacidade de usar a ferramenta `browser`. As tentativas de navegação resultavam no erro persistente "Error: Failed to start Chrome CDP on port 18800 for profile 'openclaw'. Chrome stderr: Authorization required, but no authorization protocol specified [...] Missing X server or $DISPLAY [...] The platform failed to initialize. Exiting."

**Análise Inicial:**
*   A navegação funcionava antes da atualização.
*   A execução do gateway via `systemctl --user` resultava em um ambiente sem acesso às variáveis gráficas (`$DISPLAY`, `XAUTHORITY`).
*   O servidor Manjaro apresentava problemas gráficos locais (tela de login do XFCE travada) após a instalação de uma ferramenta de acesso remoto, tornando inviável o acesso direto a um X server real.
*   Tentativas de configurar `browser.noSandbox: true`, `export DISPLAY=:0.0` e `xhost +local:` não resolveram, pois o problema era mais fundamental: o processo do OpenClaw não conseguia "enxergar" um X server funcional. Mesmo o `xhost` falhava com "Authorization required", indicando um problema com o próprio ambiente gráfico do usuário `maykon` ao tentar interagir com o X server.
*   O modo headless do Chrome ainda exige um display X (real ou virtual).

**Solução Encontrada:**
A solução foi implementar um **X Virtual Framebuffer (XVFB)** para simular um display gráfico em memória, desacoplando a necessidade do browser de um X server físico funcional.

**Passos:**
1.  **Instalação do XVFB:**
    `sudo pacman -S xorg-server-xvfb` (no Manjaro)
2.  **Verificação e Ajuste de Permissões (se necessário):**
    Identificado que `/dev/dri/card0` tinha grupo `video`. O usuário `maykon` foi adicionado ao grupo `video` para resolver o erro `libEGL warning: failed to open /dev/dri/card0: Permission denied` ao iniciar o XVFB.
    `sudo usermod -aG video maykon`
    **(Importante: Logout e Login da sessão de usuário necessários após a adição ao grupo)**
3.  **Início do XVFB:**
    `Xvfb :99 -screen 0 1024x768x24 &`
    Este comando inicia o servidor X virtual no display `:99` em segundo plano.
4.  **Configuração da Variável `$DISPLAY`:**
    `export DISPLAY=:99`
    Esta variável deve ser configurada no ambiente onde o gateway do OpenClaw é executado.
5.  **Início Manual do Gateway OpenClaw:**
    Para teste, o serviço `systemctl --user openclaw-gateway.service` foi parado (`systemctl --user stop openclaw-gateway.service`), e o gateway foi iniciado manualmente no terminal onde `$DISPLAY` foi exportado (`openclaw gateway start`).

**Resultado:**
Após a configuração do XVFB e a correta definição do `$DISPLAY`, o OpenClaw foi capaz de iniciar o navegador (`browser(action="navigate", url="https://www.google.com")`) com sucesso, restaurando sua capacidade de acesso à internet.

**Conclusão:**
O XVFB provou ser uma solução robusta para ambientes headless onde o acesso a um X server físico é problemático ou inexistente, permitindo que aplicações que dependem de um display gráfico (como o Chrome) funcionem de forma virtualizada.
