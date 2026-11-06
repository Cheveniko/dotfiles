# dotfiles

My dotfiles setup for zsh, wezterm, neovim and brew formulae.

# AI SLOP

Mi configuración de macOS: Zsh, WezTerm y Neovim. Este repo continúa el historial de
`neovim-btw`; no es una configuración nueva de Neovim desde cero.

```text
.
├── Brewfile
├── zsh/.zshrc
├── wezterm/.wezterm.lua
├── nvim/.config/nvim/
├── opencode/.config/opencode/
├── claude/.claude/
├── ideavim/.ideavimrc
├── git/
└── scripts/install.sh
```

## Instalar en una Mac nueva

### 1. Homebrew y aplicaciones

Instalar las Command Line Tools de Xcode y [Homebrew](https://brew.sh/). Después,
clonar este repo y ejecutar desde su carpeta:

```sh
brew bundle --file=Brewfile
```

La lista es deliberadamente pequeña. No incluye FZF, Bun, Codex, cloudflared,
wget, FFmpeg ni LuaRocks. Homebrew resuelve las dependencias internas; algunas
herramientas pueden traer Node o Python como dependencia, pero no se usan como
gestores de las versiones de los proyectos.

### 2. Oh My Zsh y NVM

En una Mac donde esas carpetas todavía no existan:

```sh
git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting"
git clone --branch v0.41.0 --depth 1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
```

No volver a clonar sobre instalaciones existentes. El plugin `nvm` ya forma parte
de Oh My Zsh; no se instala otro gestor ni se carga `nvm.sh` dos veces.

### 3. Enlazar los archivos

El instalador no necesita Stow ni Python y no instala paquetes. Primero revisar:

```sh
bash scripts/install.sh --dry-run --backup
```

Para aplicar y respaldar cualquier archivo o carpeta existente:

```sh
bash scripts/install.sh --backup
```

Los respaldos quedan en `~/.local/state/dotfiles/backups/` (o bajo
`$XDG_STATE_HOME`). El instalador se puede repetir y nunca sobrescribe un archivo
existente sin respaldo. No mover este checkout después de crear los enlaces.

La estructura también es compatible con GNU Stow. Como alternativa al instalador,
con los destinos libres:

```sh
stow --simulate --verbose --target="$HOME" zsh wezterm nvim
stow --verbose --target="$HOME" zsh wezterm nvim
```

### 4. Versiones de Node y Python

Abrir una shell nueva y preparar Node:

```sh
nvm install 24
nvm alias default 24
nvm use 24
```

Node 24 es la versión base. Instalar la última revisión de Node 22 solamente si un
proyecto lo necesita. Respetar la `.nvmrc` de cada proyecto con `nvm use` y la
versión de pnpm indicada en su `package.json`; no actualizar los proyectos en
bloque. No se instalan versiones faltantes automáticamente al cambiar de carpeta.

Python se gestiona exclusivamente con uv, no con el Python de macOS ni con pyenv:

```sh
uv python install 3.14 --default
uv python pin --global 3.14
```

`--default` crea los ejecutables `python` y `python3` en `~/.local/bin`, que ya está
en el PATH. Esta opción está marcada como experimental en uv. En cada proyecto,
usar `.python-version`, `pyproject.toml`, `uv.lock` y un entorno `.venv` propio;
ejecutar sus herramientas con `uv run`. No instalar paquetes globalmente con pip.

### 5. Neovim y servicios locales

Esta configuración requiere Neovim 0.12. En el primer arranque, Lazy instala los
plugins siguiendo `lazy-lock.json`; Mason instala los servidores configurados y
StyLua. Revisar `:checkhealth`, `:Mason` y `:ConformInfo` después de instalar.

Los formateadores de Conform distintos de StyLua no se instalan automáticamente
en esta configuración. Instalar solo los que necesite cada proyecto. El preview
de Markdown utiliza Yarn durante su compilación; Telescope compila su extensión
nativa con `make`, provisto por las Command Line Tools.

Java 21 queda en `JAVA_HOME`; el servidor de Kotlin usa el JDK 21 de Homebrew.
PostgreSQL permanece en la versión 17 y Dadbod encuentra `psql` en el PATH.
Instalar servicios no implica iniciarlos. Cuando se necesiten:

```sh
brew services start postgresql@17
brew services start redis
```

### 6. OpenCode y Claude Code

El mismo instalador enlaza cinco archivos de configuración pública:

```text
~/.config/opencode/opencode.json
~/.config/opencode/cli.json
~/.config/opencode/AGENTS.md
~/.claude/settings.json
~/.claude/CLAUDE.md
```

Se enlazan los archivos individuales, no las carpetas completas. Los datos de las
aplicaciones, credenciales, sesiones y skills existentes quedan intactos. Al
volver a ejecutar `bash scripts/install.sh --backup`, solo se respaldan y enlazan
los archivos que todavía no apuntan a este checkout.

La configuración de OpenCode incluye el endpoint público del MCP de Linear, sin
tokens. En la nueva Mac, iniciar sesión en OpenCode y volver a autenticar Linear
desde `/mcps`. Para forzar una recarga de la configuración, usar `/reload`.

En Claude Code, iniciar sesión nuevamente y reinstalar el plugin oficial de
Figma si no estuviera disponible. Se conservan tus preferencias actuales sin
migrar `~/.claude.json`, credenciales ni historiales.

Las skills no se incluyen en el repo público: su respaldo y sus licencias se
gestionan por separado. Codex continúa fuera de esta configuración.

### 7. Git e IdeaVim

El instalador también enlaza estos archivos, con respaldo de cualquier versión
existente:

```text
~/.ideavimrc
~/.gitconfig
~/.config/git/ignore
```

IdeaVim conserva tus mappings y opciones. Instalar el plugin IdeaVim desde el IDE
de JetBrains que utilices; este repo no instala los IDE ni sus plugins.

La configuración de Git conserva tu identidad actual con el correo noreply de
GitHub. El ignore global evita subir `**/.claude/settings.local.json` por error;
Git utiliza `~/.config/git/ignore` de forma predeterminada cuando no se configura
otro `core.excludesFile` ni se cambia `XDG_CONFIG_HOME`.

Raycast se restaura desde su respaldo privado en la nube. VS Code no se incluye.

## Arranque rápido de Zsh

Se conserva Oh My Zsh con el tema `miloshadzic`, autocompletado, sugerencias y
resaltado. NVM se carga bajo demanda al usar `node`, `npm`, `pnpm`, Yarn o el propio
`nvm`. También se carga antes de `nvim` y `eas` para que sus procesos hijos reciban
la versión correcta de Node. Los alias `vim`, `dadbod`, etc. pasan por `nvim`.

El primer comando que necesite Node paga el coste de inicialización; abrir una
pestaña para otros comandos no. El PATH se prepara antes del plugin para no
volver a poner el Node de Homebrew por delante del seleccionado por NVM.

Los procesos que omitan los wrappers de Zsh (por ejemplo `command node` o una
aplicación gráfica abierta desde Finder) no activan esta carga diferida.

En la Mac original, la mediana de cinco arranques con cachés calientes pasó de
494 ms a 77 ms hasta el prompt. La medición usa una pseudoterminal y no incluye
la creación ni el renderizado de una ventana de WezTerm. El primer arranque puede
tardar más mientras se generan las cachés de completado.

## WezTerm

Se conservan colores, fuentes, fullscreen y atajos. Se mantiene
`front_end = "OpenGL"` para conservar la apariencia original de las fuentes.
Se probó `WebGpu` (Metal en macOS), pero las letras se percibían más gruesas.
La mejora del arranque de Zsh no depende del renderizador de WezTerm.

El Brewfile usa el canal estable. La versión instalada al preparar este repo,
`20240203-110809-5046fc22`, era también la última marcada como estable en GitHub.
No se instala una nightly automáticamente.

## Archivos privados

Este repo es público. No incluir credenciales, historial de shell, conexiones de
Dadbod, volcados de bases ni claves SSH. `~/.local/share/db_ui/` no se copia, enlaza
ni modifica. Los respaldos del instalador quedan fuera del repo.

Para ajustes privados de esta Mac, usar `~/.zshrc.local`, cargado al final de Zsh.
El `.gitignore` es una protección adicional, no un reemplazo de revisar cada diff
antes de publicar. Nunca usar `git add -f` para subir secretos.

## Renombrar el repo existente

Renombrar `Cheveniko/neovim-btw` a `Cheveniko/dotfiles` en GitHub conserva su
historial. Después, actualizar el remoto de este checkout:

```sh
git remote set-url origin https://github.com/Cheveniko/dotfiles.git
```

No hace falta crear otro repo remoto ni sobrescribir el historial.

## Comprobar el instalador

Las pruebas usan homes temporales; no modifican los dotfiles reales:

```sh
uv run --python 3.14 --no-project python -m unittest discover -s tests -v
```

## Créditos

La configuración de Neovim partió de
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). Se conserva su
[README original](nvim/.config/nvim/README.md), documentación y la licencia MIT
en [LICENSE.md](LICENSE.md).
