---
title: Inicio rapido
section: guide
order: 1
locale: es
---

## Requisitos

- macOS 13.0 (Ventura) o posterior
- Privilegios de administrador (para la configuracion inicial y el cambio de iconos)

## Instalacion

### Homebrew (recomendado)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Descarga manual

1. Descargue el DMG mas reciente desde [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Abra el DMG y arrastre **IconChanger** a su carpeta de Aplicaciones.
3. Inicie IconChanger.

## Primer inicio

En el primer inicio, IconChanger le solicitara completar una configuracion de permisos que solo se realiza una vez. Esto es necesario para que la aplicacion pueda cambiar los iconos de las aplicaciones.

![Pantalla de configuracion del primer inicio](/images/setup-prompt.png)

Haga clic en el boton de configuracion e introduzca su contrasena de administrador. IconChanger configurara automaticamente los permisos necesarios (una regla de sudoers para el script auxiliar).

::: tip
Si la configuracion automatica falla, consulte [Configuracion inicial](./setup) para instrucciones manuales.
:::

## Cambiar su primer icono

1. Seleccione una aplicacion de la barra lateral.
2. Busque iconos en [macOSicons.com](https://macosicons.com/) o elija un archivo de imagen local.
3. Haga clic en un icono para aplicarlo.

![Interfaz principal](/images/main-interface.png)

Eso es todo. El icono de la aplicacion se cambiara de inmediato.

## Siguientes pasos

- [Configurar una clave API](./api-key) para la busqueda de iconos en linea
- [Conocer los alias de aplicaciones](./aliases) para obtener mejores resultados de busqueda
- [Configurar el servicio en segundo plano](./background-service) para la restauracion automatica de iconos
- [Instalar la herramienta CLI](/es/cli/) para acceso desde la linea de comandos