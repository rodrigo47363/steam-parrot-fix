# Solución: Steam no abre en Parrot OS (bibliotecas 32-bit)

## Problema

Al ejecutar `steam` en Parrot OS 7.4, el cliente no iniciaba mostrando el error:

```
You are missing the following 32-bit libraries, and Steam may not run:
libc.so.6
```

Incluso tras instalar algunas dependencias, el cliente tradicional de 32 bits fallaba al cargar `steamui.so` con el error:

```
dlmopen .../steamui.so failed: libGL.so.1: wrong ELF class: ELFCLASS64
```

Además, al intentar instalar las librerías gráficas 32-bit (`libgl1:i386`, `libegl1:i386`, `libgbm1:i386`, etc.), `apt` reportaba paquetes rotos debido a conflictos de versiones entre los repositorios de Parrot (amd64) y Debian trixie (i386), especialmente en `zlib1g`, `liblzma5` y `libexpat1`.

---

## Entorno

| Elemento | Detalle |
|----------|---------|
| SO | Parrot OS 7.4 |
| Entorno de escritorio | bspwm sobre X11 |
| Arquitectura | amd64 con arquitectura i386 habilitada |
| GPU | Intel UHD Graphics (CometLake-H) + NVIDIA GeForce RTX 3050 Mobile |
| Steam | Instalado vía repositorios oficiales (`steam:i386`, `steam-launcher:amd64`, etc.) |

---

## Pasos para solucionarlo

### Paso 1: Instalar las librerías básicas 32-bit

El primer error se debía a la ausencia de `libc6:i386`. Se instaló con:

```bash
pkexec apt-get update
pkexec apt-get install -y libc6:i386 libgcc-s1:i386
```

> Nota: En este entorno se usó `pkexec` porque `sudo` requería contraseña.

### Paso 2: Activar el cliente nativo 64-bit de Steam

Steam ya trae descargado un cliente nativo de **64 bits** en:

```
~/.local/share/Steam/steamrt64/steam
```

Para forzar que Steam use este cliente en lugar del de 32 bits (`ubuntu12_32/steam`), se creó el archivo de marca:

```bash
touch ~/.local/share/Steam/.steam-enable-steamrt64-client
```

Al reiniciar Steam, el lanzador detecta este archivo y ejecuta `steamrt64/steam` utilizando el runtime Pressure-Vessel y las librerías 64-bit del sistema, evitando los conflictos de las librerías 32-bit.

### Paso 3: Ejecutar Steam

```bash
steam
```

Tras esto, Steam inicia correctamente y muestra la pantalla de inicio de sesión ("Sign in to Steam").

---

## Comandos resumidos

```bash
# 1. Instalar libc 32-bit y dependencias básicas
pkexec apt-get install -y libc6:i386 libgcc-s1:i386

# 2. Activar cliente 64-bit de Steam
touch ~/.local/share/Steam/.steam-enable-steamrt64-client

# 3. Ejecutar Steam
steam
```

---

## Notas importantes

- El aviso de "missing 32-bit libraries" (`libegl1:i386`, `libgbm1:i386`, `libgl1:i386`, etc.) puede seguir apareciendo, pero **no impide** que el cliente funcione, ya que SteamRT64 usa su propio runtime con las librerías gráficas incluidas.
- El archivo `.steam-enable-steamrt64-client` es una marca interna de Steam; no necesita contenido, solo debe existir.
- Para juegos que requieran aceleración de hardware (OpenGL/Vulkan), puede ser necesario configurar `DRI_PRIME` o instalar controladores adicionales según la GPU.

---

## Archivos y rutas relevantes

| Ruta | Descripción |
|------|-------------|
| `/usr/bin/steam` | Lanzador de Steam (symlink a `bin_steam.sh`) |
| `~/.local/share/Steam/ubuntu12_32/steam` | Cliente tradicional de 32 bits |
| `~/.local/share/Steam/steamrt64/steam` | Cliente nativo de 64 bits |
| `~/.local/share/Steam/.steam-enable-steamrt64-client` | Marca para activar el cliente 64-bit |
| `~/.local/share/Steam/logs/console-linux.txt` | Log principal de Steam |

---

*Documentación creada para registrar la solución en Parrot OS.*