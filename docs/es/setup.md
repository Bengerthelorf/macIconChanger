---
title: Configuracion inicial
section: guide
order: 2
locale: es
---

IconChanger necesita privilegios de administrador para cambiar los iconos de las aplicaciones. En el primer inicio, la aplicacion ofrece configurar esto automaticamente.

## Configuracion automatica (recomendada)

1. Inicie IconChanger.
2. Haga clic en el boton **Setup** cuando se le solicite.
3. Introduzca su contrasena de administrador.

La aplicacion instalara un script auxiliar en `/usr/local/lib/iconchanger/` (propiedad de `root:wheel`) y configurara una regla de sudoers delimitada para que pueda ejecutarse sin solicitar contrasena cada vez.

## Seguridad

IconChanger utiliza varias medidas de seguridad para proteger el pipeline auxiliar:

- **Directorio auxiliar propiedad de root** — Los archivos auxiliares se encuentran en `/usr/local/lib/iconchanger/` con propiedad `root:wheel`, evitando modificaciones no privilegiadas.
- **Verificacion de integridad SHA-256** — El script auxiliar se verifica contra un hash conocido antes de cada ejecucion.
- **Regla de sudoers delimitada** — La entrada de sudoers solo otorga acceso sin contrasena al script auxiliar especifico, no a comandos arbitrarios.
- **Registro de auditoria** — Todas las operaciones de iconos se registran con marcas de tiempo para su trazabilidad.

## Configuracion manual

Si la configuracion automatica falla, puede configurarlo manualmente:

1. Abra Terminal.
2. Ejecute:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Agregue la siguiente linea:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verificar la configuracion

Despues de la configuracion, la aplicacion deberia mostrar la lista de aplicaciones en la barra lateral. Si vuelve a ver el mensaje de configuracion, es posible que la configuracion no se haya aplicado correctamente.

Puede verificar la configuracion desde la barra de menus: haga clic en el menu **...** y seleccione **Check Setup Status**.

## Limitaciones

Las aplicaciones protegidas por la Proteccion de Integridad del Sistema (SIP) de macOS no pueden tener sus iconos modificados. Esta es una restriccion de macOS y no se puede eludir.

Las aplicaciones protegidas por SIP mas comunes incluyen:
- Finder
- Safari (en algunas versiones de macOS)
- Otras aplicaciones del sistema en `/System/Applications/`