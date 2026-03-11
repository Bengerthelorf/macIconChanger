# Servicio en segundo plano

El servicio en segundo plano mantiene intactos sus iconos personalizados, incluso despues de actualizaciones de aplicaciones o cambios del sistema.

## Activacion

Vaya a **Settings** > **Background** y active **Run in Background**.

Cuando esta activado, IconChanger continua ejecutandose despues de cerrar la ventana. Puede acceder a el desde la barra de menus o el Dock.

## Funciones

### Restauracion programada

Restaure automaticamente todos los iconos personalizados almacenados en cache a intervalos regulares.

- Active **Restore Icons on Schedule**
- Elija un intervalo: cada hora, 3 horas, 6 horas, 12 horas, diariamente o un intervalo personalizado
- La configuracion muestra cuando ocurrieron la ultima y la proxima restauracion

### Deteccion de actualizaciones de aplicaciones

Detecte cuando se actualizan las aplicaciones y reaplique automaticamente sus iconos personalizados.

- Active **Restore Icons When Apps Update**
- Establezca con que frecuencia verificar las actualizaciones (cada 5 minutos a cada 2 horas, o personalizado)

### Visibilidad de la aplicacion

Controle donde aparece IconChanger cuando se ejecuta en segundo plano:

- **Show in Menu Bar** — agrega un icono a la barra de menus
- **Show in Dock** — mantiene la aplicacion en el Dock

Al menos una de estas opciones debe estar activada.

### Iniciar al iniciar sesion

Inicie IconChanger automaticamente cuando inicie sesion en su Mac.

- **Open Main Window** — inicia normalmente con la ventana principal
- **Start Hidden** — inicia silenciosamente en segundo plano (requiere que "Run in Background" este activado)

::: info
"Start Hidden" solo afecta al inicio de sesion. Abrir la aplicacion manualmente siempre mostrara la ventana principal.
:::

## Estado del servicio

Cuando el servicio en segundo plano esta activo, la pagina de configuracion muestra:
- **Service Status** — si el servicio esta en ejecucion
- **Cached Icons** — cuantos iconos estan listos para restauracion
