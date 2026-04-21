---
title: Configuracao Inicial
section: guide
order: 2
locale: pt
---

O IconChanger precisa de privilegios de administrador para alterar icones de aplicativos. Na primeira execucao, o app oferece a opcao de configurar isso automaticamente.

## Configuracao Automatica (Recomendado)

1. Abra o IconChanger.
2. Clique no botao **Setup** quando solicitado.
3. Insira sua senha de administrador.

O app instalara um script auxiliar em `/usr/local/lib/iconchanger/` (propriedade de `root:wheel`) e configurara uma regra sudoers delimitada para que possa ser executado sem solicitar senha a cada vez.

## Seguranca

O IconChanger utiliza diversas medidas de seguranca para proteger o pipeline auxiliar:

- **Diretorio auxiliar de propriedade do root** — Os arquivos auxiliares ficam em `/usr/local/lib/iconchanger/` com propriedade `root:wheel`, impedindo modificacoes nao privilegiadas.
- **Verificacao de integridade SHA-256** — O script auxiliar e verificado contra um hash conhecido antes de cada execucao.
- **Regra sudoers delimitada** — A entrada sudoers concede acesso sem senha apenas ao script auxiliar especifico, nao a comandos arbitrarios.
- **Registro de auditoria** — Todas as operacoes de icones sao registradas com carimbos de data/hora para rastreabilidade.

## Configuracao Manual

Se a configuracao automatica falhar, voce pode configura-la manualmente:

1. Abra o Terminal.
2. Execute:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Adicione a seguinte linha:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verificando a Configuracao

Apos a configuracao, o app deve exibir a lista de aplicativos na barra lateral. Se voce vir o prompt de configuracao novamente, a configuracao pode nao ter sido aplicada corretamente.

Voce pode verificar a configuracao pela barra de menus: clique no menu **...** e selecione **Check Setup Status**.

## Limitacoes

Aplicativos protegidos pelo System Integrity Protection (SIP) do macOS nao podem ter seus icones alterados. Esta e uma restricao do macOS e nao pode ser contornada.

Apps comuns protegidos pelo SIP incluem:
- Finder
- Safari (em algumas versoes do macOS)
- Outros aplicativos do sistema em `/System/Applications/`