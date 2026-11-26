# Steam Fix for Parrot OS 🦜🎮

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Parrot OS](https://img.shields.io/badge/Parrot%20OS-7.4-blue?logo=linux)](https://www.parrotsec.org/)
[![Steam](https://img.shields.io/badge/Steam-Client%20Fix-1b2838?logo=steam&logoColor=white)](https://store.steampowered.com/)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](fix-steam-parrot.sh)

> Solución automática al error de librerías 32-bit de Steam en Parrot OS, activando el cliente nativo 64-bit (SteamRT64).

---

## ⚡ Instalación rápida (1 comando)

```bash
curl -sSL https://raw.githubusercontent.com/rodrigo47363/steam-parrot-fix/main/fix-steam-parrot.sh | bash
```

> O si prefieres revisar el script antes de ejecutarlo (recomendado):
> ```bash
> curl -sSL https://raw.githubusercontent.com/rodrigo47363/steam-parrot-fix/main/fix-steam-parrot.sh -o fix-steam-parrot.sh
> chmod +x fix-steam-parrot.sh
> ./fix-steam-parrot.sh
> ```

---

## 🐛 El Problema

Al ejecutar `steam` en **Parrot OS 7.4**, el cliente no iniciaba mostrando:

```
You are missing the following 32-bit libraries, and Steam may not run:
libc.so.6
```

Y tras instalar dependencias, el cliente de 32 bits fallaba con:

```
dlmopen .../steamui.so failed: libGL.so.1: wrong ELF class: ELFCLASS64
```

Instalar las librerías gráficas 32-bit (`libgl1:i386`, `libegl1:i386`, `libgbm1:i386`, etc.) causaba conflictos en `apt` entre los repositorios de Parrot (amd64) y Debian trixie (i386):
- `zlib1g`, `liblzma5`, `libexpat1` — versiones incompatibles

---

## ✅ La Solución

Steam incluye un **cliente nativo 64-bit** (`steamrt64/steam`) que usa el runtime Pressure-Vessel y sus propias librerías gráficas, evitando todos los conflictos 32-bit del sistema.

Solo hay que crear un archivo marcador para que el lanzador lo active:

```bash
touch ~/.local/share/Steam/.steam-enable-steamrt64-client
```

---

## 🔧 Uso del Script

```bash
./fix-steam-parrot.sh              # Flujo completo (recomendado)
./fix-steam-parrot.sh --only-libs  # Solo instala librerías 32-bit
./fix-steam-parrot.sh --only-64bit # Solo activa el cliente 64-bit
./fix-steam-parrot.sh --verify     # Verifica el estado del sistema
./fix-steam-parrot.sh --help       # Muestra la ayuda
```

---

## 📋 Pasos Manuales

Si prefieres hacerlo a mano:

```bash
# 1. Instalar librerías básicas 32-bit
pkexec apt-get install -y libc6:i386 libgcc-s1:i386

# 2. Activar cliente 64-bit de Steam
touch ~/.local/share/Steam/.steam-enable-steamrt64-client

# 3. Ejecutar Steam
steam
```

---

## 💻 Entorno Probado

| Elemento | Detalle |
|----------|---------|
| SO | Parrot OS 7.4 |
| Entorno de escritorio | bspwm sobre X11 |
| Arquitectura | amd64 con i386 habilitado |
| GPU | Intel UHD Graphics (CometLake-H) + NVIDIA RTX 3050 Mobile |
| Steam | Instalado vía repositorios oficiales |

---

## 📁 Rutas Relevantes

| Ruta | Descripción |
|------|-------------|
| `/usr/bin/steam` | Lanzador de Steam (symlink a `bin_steam.sh`) |
| `~/.local/share/Steam/ubuntu12_32/steam` | Cliente tradicional 32-bit |
| `~/.local/share/Steam/steamrt64/steam` | **Cliente nativo 64-bit** ✅ |
| `~/.local/share/Steam/.steam-enable-steamrt64-client` | Marcador para activar el cliente 64-bit |
| `~/.local/share/Steam/logs/console-linux.txt` | Log principal de Steam |

---

## ❓ FAQ

**¿Seguirán apareciendo avisos de "missing 32-bit libraries"?**
Sí, pero son **inofensivos**. SteamRT64 usa su propio runtime con todas las librerías gráficas incluidas.

**¿Funciona con juegos que requieren OpenGL/Vulkan?**
Sí en la mayoría de los casos. Para configuraciones NVIDIA+Intel puede ser necesario `DRI_PRIME=1` o instalar el driver propietario.

**¿Funciona en otras distribuciones Debian?**
Probablemente sí si tienes el mismo conflicto de repositorios i386/amd64 con Debian trixie.

---

## 🤝 Contribuir

1. Haz un **fork** del repositorio.
2. Crea una rama (`git checkout -b feature/mi-mejora`).
3. Haz tus cambios y ejecuta `shellcheck fix-steam-parrot.sh` para validar.
4. Envía un **Pull Request**.

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

*Documentado y mantenido por [@rodrigo47363](https://github.com/rodrigo47363)*
