# Configuracion inicial

IconChanger necesita privilegios de administrador para cambiar los iconos de las aplicaciones. En el primer inicio, la aplicacion ofrece configurar esto automaticamente.

## Configuracion automatica (recomendada)

1. Inicie IconChanger.
2. Haga clic en el boton **Setup** cuando se le solicite.
3. Introduzca su contrasena de administrador.

La aplicacion creara un script auxiliar en `~/.iconchanger/helper.sh` y configurara una regla de sudoers para que pueda ejecutarse sin solicitar contrasena cada vez.

## Configuracion manual

Si la configuracion automatica falla, puede configurarlo manualmente:

1. Abra Terminal.
2. Ejecute:

```bash
sudo visudo
```

3. Agregue la siguiente linea al final:

```
ALL ALL=(ALL) NOPASSWD: /Users/<su-nombre-de-usuario>/.iconchanger/helper.sh
```

Reemplace `<su-nombre-de-usuario>` con su nombre de usuario real de macOS.

## Verificar la configuracion

Despues de la configuracion, la aplicacion deberia mostrar la lista de aplicaciones en la barra lateral. Si vuelve a ver el mensaje de configuracion, es posible que la configuracion no se haya aplicado correctamente.

Puede verificar la configuracion desde la barra de menus: haga clic en el menu **...** y seleccione **Check Setup Status**.

## Limitaciones

Las aplicaciones protegidas por la Proteccion de Integridad del Sistema (SIP) de macOS no pueden tener sus iconos modificados. Esta es una restriccion de macOS y no se puede eludir.

Las aplicaciones protegidas por SIP mas comunes incluyen:
- Finder
- Safari (en algunas versiones de macOS)
- Otras aplicaciones del sistema en `/System/Applications/`
