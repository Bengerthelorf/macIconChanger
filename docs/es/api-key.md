---
title: Clave API
section: guide
order: 7
locale: es
---

Se requiere una clave API de [macosicons.com](https://macosicons.com/) para buscar iconos en linea. Sin ella, aun puede utilizar archivos de imagen locales.

## Obtener una clave API

1. Visite [macosicons.com](https://macosicons.com/) y cree una cuenta.
2. Solicite una clave API desde la configuracion de su cuenta.
3. Copie la clave.

![Como obtener una clave API](/images/api-key.png)

## Introducir la clave

1. Abra IconChanger.
2. Vaya a **Settings** > **Advanced**.
3. Pegue su clave API en el campo **API Key**.
4. Haga clic en **Test Connection** para verificar que funciona.

![Configuracion de clave API](/images/api-key-settings.png)

## Uso sin clave API

Aun puede cambiar los iconos de las aplicaciones sin una clave API mediante:

- Archivos de imagen locales (haga clic en **Choose from the Local** o arrastre y suelte una imagen)
- Iconos incluidos dentro de la propia aplicacion (mostrados en la seccion "Local")

## Configuracion avanzada de API

En **Settings** > **Advanced** > **API Settings**, puede ajustar el comportamiento de la API:

| Configuracion | Predeterminado | Descripcion |
|---|---|---|
| **Retry Count** | 0 (sin reintentos) | Cuantas veces reintentar una solicitud fallida (0–3) |
| **Timeout** | 15 segundos | Tiempo de espera por cada intento de solicitud |
| **Monthly Limit** | 50 | Consultas API maximas por mes |

El contador **Monthly Usage** muestra su uso actual. Se reinicia automaticamente el dia 1 de cada mes, o puede reiniciarlo manualmente.

### Cache de busqueda de iconos

Active **Cache API Results** para guardar los resultados de busqueda en disco. Los resultados almacenados en cache persisten entre reinicios de la aplicacion, lo que reduce el uso de la API. Use el boton de actualizar al explorar iconos para obtener resultados actualizados.

## Solucion de problemas

Si la prueba de la API falla:
- Verifique que su clave sea correcta (sin espacios adicionales)
- Compruebe su conexion a internet
- La API de macosicons.com puede estar temporalmente no disponible