# Inicio Rapido

## Requisitos

- macOS 13.0 (Ventura) ou posterior
- Privilegios de administrador (para a configuracao inicial e alteracao de icones)

## Instalacao

### Homebrew (Recomendado)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Download Manual

1. Baixe o DMG mais recente em [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Abra o DMG e arraste o **IconChanger** para a pasta Aplicativos.
3. Abra o IconChanger.

## Primeira Execucao

Na primeira execucao, o IconChanger solicitara que voce conclua uma configuracao unica de permissoes. Isso e necessario para que o app possa alterar os icones dos aplicativos.

![Tela de configuracao inicial](/images/setup-prompt.png)

Clique no botao de configuracao e insira sua senha de administrador. O IconChanger configurara automaticamente as permissoes necessarias (uma regra sudoers para o script auxiliar).

::: tip
Se a configuracao automatica falhar, consulte [Configuracao Inicial](./setup) para instrucoes manuais.
:::

## Alterando Seu Primeiro Icone

1. Selecione um aplicativo na barra lateral.
2. Navegue pelos icones do [macOSicons.com](https://macosicons.com/) ou escolha um arquivo de imagem local.
3. Clique em um icone para aplica-lo.

![Interface principal](/images/main-interface.png)

Pronto! O icone do app sera alterado imediatamente.

## Proximos Passos

- [Configurar uma chave de API](./api-key) para pesquisa de icones online
- [Saiba mais sobre aliases de apps](./aliases) para melhores resultados de pesquisa
- [Configurar o servico em segundo plano](./background-service) para restauracao automatica de icones
- [Instalar a ferramenta CLI](/pt/cli/) para acesso via linha de comando
