# Configuracao Inicial

O IconChanger precisa de privilegios de administrador para alterar icones de aplicativos. Na primeira execucao, o app oferece a opcao de configurar isso automaticamente.

## Configuracao Automatica (Recomendado)

1. Abra o IconChanger.
2. Clique no botao **Setup** quando solicitado.
3. Insira sua senha de administrador.

O app criara um script auxiliar em `~/.iconchanger/helper.sh` e configurara uma regra sudoers para que possa ser executado sem solicitar senha a cada vez.

## Configuracao Manual

Se a configuracao automatica falhar, voce pode configura-la manualmente:

1. Abra o Terminal.
2. Execute:

```bash
sudo visudo
```

3. Adicione a seguinte linha no final:

```
ALL ALL=(ALL) NOPASSWD: /Users/<seu-nome-de-usuario>/.iconchanger/helper.sh
```

Substitua `<seu-nome-de-usuario>` pelo seu nome de usuario real do macOS.

## Verificando a Configuracao

Apos a configuracao, o app deve exibir a lista de aplicativos na barra lateral. Se voce vir o prompt de configuracao novamente, a configuracao pode nao ter sido aplicada corretamente.

Voce pode verificar a configuracao pela barra de menus: clique no menu **...** e selecione **Check Setup Status**.

## Limitacoes

Aplicativos protegidos pelo System Integrity Protection (SIP) do macOS nao podem ter seus icones alterados. Esta e uma restricao do macOS e nao pode ser contornada.

Apps comuns protegidos pelo SIP incluem:
- Finder
- Safari (em algumas versoes do macOS)
- Outros aplicativos do sistema em `/System/Applications/`
