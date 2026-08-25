# granola-export-cron

Backup automático semanal de tus notas de reuniones de Granola (plan free,
que las borra a los 30 días) a una carpeta local **y** a una carpeta en
Google Drive.

Cada reunión se guarda como Markdown, en dos lugares:

1. **Local** — `~/Granola-Backup/`
2. **Google Drive** — carpeta llamada exactamente `Granola Backup`
   (se crea sola la primera vez que corre, en tu propia cuenta de Drive)

Cada nota incluye: título, fecha, asistentes, tus notas privadas, y el
resumen generado por IA. El transcript solo está disponible en el plan
pago de Granola — en el plan free queda marcado como no disponible.

El dedup es por archivo: el nombre local termina en `_<8 primeros
caracteres del UUID>.md`, así que correr el script de nuevo nunca duplica
una reunión ya exportada.

## Requisitos

- macOS (usa `launchd` para el scheduling).
- [Claude Code](https://claude.com/claude-code) instalado, con el binario
  accesible en `~/.local/bin/claude`.
- En Claude, los conectores MCP de **Granola** y **Google Drive**
  conectados bajo tu propia cuenta (Configuración → Conectores en
  claude.ai). El backup usa tus credenciales, no las de nadie más.

## Instalación

```sh
git clone <url-de-este-repo>
cd granola-export-cron
./install.sh
```

Esto copia los archivos a su lugar y registra el cron (`launchd`), que
corre **los lunes a las 10:00**. Podés probarlo ya mismo con:

```sh
~/.local/bin/granola-export.sh && cat ~/Granola-Backup/.export.log
```

## Cómo funciona

| Pieza | Path (una vez instalado) | Rol |
|-------|---------------------------|-----|
| Schedule | `~/Library/LaunchAgents/com.granola-export.plist` | agente de `launchd`, corre los lunes 10:00 (o al despertar la Mac si estaba dormida) |
| Runner | `~/.local/bin/granola-export.sh` | wrapper que lanza `launchd`; loguea en `.export.log` |
| Lógica | `~/.claude/granola-export-prompt.md` | instrucciones para el agente headless `claude -p` que hace el export |
| Log | `~/Granola-Backup/.export.log` | output de cada corrida (qué se exportó / qué se saltó) |

**Fuente de datos:** conector MCP de Granola (lectura) + conector MCP de
Google Drive (escritura), vía una corrida headless de `claude -p`. La API
de Granola solo lista los **últimos 30 días**, por eso el cron tiene que
seguir corriendo semanalmente para no perder notas antes de que expiren.

## Comandos útiles

```sh
# Correr el backup ahora mismo (también sirve para testear)
~/.local/bin/granola-export.sh

# Ver el log de la última corrida
cat ~/Granola-Backup/.export.log

# Confirmar que el cron está registrado
launchctl list | grep granola-export

# Cambiar día/hora: editar StartCalendarInterval en el .plist instalado, después recargar
launchctl unload ~/Library/LaunchAgents/com.granola-export.plist
launchctl load   ~/Library/LaunchAgents/com.granola-export.plist
#   (Weekday: 1 = lunes ... 0/7 = domingo)

# Desactivar el cron
launchctl unload ~/Library/LaunchAgents/com.granola-export.plist
```

## Notas / limitaciones

- El cron corre en tu Mac: tiene que estar prendida/despierta cerca del
  horario programado. Con corridas semanales dentro de una ventana de 30
  días hay bastante margen.
- Si el log muestra un error de autenticación, reconectá los conectores
  de Granola / Google Drive en claude.ai.
- No borra nada. Solo crea archivos `.md` nuevos en `~/Granola-Backup/` y
  en la carpeta de Drive.
