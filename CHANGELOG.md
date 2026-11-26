# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es/1.0.0/).

---

## [1.0.0] — 2026-11-25

### Added
- Script automatizado `fix-steam-parrot.sh` con flujo completo de reparación.
- Modos de ejecución: `--only-libs`, `--only-64bit`, `--verify`, `--help`.
- Detección automática de privilegios: soporte para `sudo` y `pkexec`.
- Verificación automática de arquitectura i386 y activación si no está habilitada.
- Instalación de librerías 32-bit básicas (`libc6:i386`, `libgcc-s1:i386`) y opcionales gráficas.
- Activación del cliente nativo 64-bit de Steam (`SteamRT64`) mediante archivo marcador.
- Verificación final del sistema con resumen visual.
- `README.md` profesional con badges, FAQ, rutas y guía de contribución.
- `LICENSE` MIT.
- GitHub Actions CI con ShellCheck para validar el script en cada push.
- Plantillas de issues: bug report y feature request.

### Fixed
- Error `libc.so.6 missing 32-bit library` al arrancar Steam.
- Error `dlmopen steamui.so failed: libGL.so.1: wrong ELF class: ELFCLASS64`.
- Conflictos de paquetes `zlib1g`, `liblzma5`, `libexpat1` entre repos amd64/i386.

### Documentation
- `STEAM_PARROT_FIX.md` conservado como referencia del análisis original del problema.
