# Auditor Claude

Guardarraíles de integridad para proyectos hechos con ayuda de IA.

Las herramientas de código con IA (Codex, etc.) tienden a **trucar** los
scripts para que *parezcan* funcionar: commitean archivos de resultados que
ningún script genera, dejan el CI en verde sin tests reales, o hardcodean
salidas. Auditor Claude existe para que eso sea **imposible de colar**:
detecta esos patrones y te instala las defensas automáticas.

## Qué incluye

| Archivo | Para qué |
|:---|:---|
| `audit.sh` | Auditor standalone. Corre en cualquier repo y marca CI que traga fallos, ausencia de tests, y ficheros de resultados sin generador. |
| `install.sh` | Instala los guardarraíles en un proyecto (sin sobrescribir nada). |
| `templates/CLAUDE.md` | Reglas de integridad no-negociables que cualquier agente lee antes de tocar el repo. |
| `templates/Makefile` | `make test` / `smoke` / `data` / `check-reproducible` / `audit`. |
| `templates/ci.yml` | CI honesto: tests reales + paso que **regenera los datos y falla si difieren** de lo commiteado. |

## Instalación

```bash
git clone https://github.com/nacho09021973/auditor-claude.git
cd auditor-claude
```

(Opcional) tener `audit` a mano en cualquier sitio:

```bash
ln -s "$PWD/audit.sh" ~/.local/bin/audit-claude   # asegúrate de que ~/.local/bin está en tu PATH
```

## Uso

**Auditar un repo** (detecta trucos sin cambiar nada):

```bash
bash audit.sh /ruta/a/tu/repo      # o, dentro del repo: bash /ruta/a/auditor-claude/audit.sh
```

**Instalar los guardarraíles** en un proyecto:

```bash
bash install.sh /ruta/a/tu/repo
# luego rellena los "### FILL ME" en CLAUDE.md y Makefile, y commitea
```

## La regla que hace el trabajo pesado

> Todo número publicado es la salida literal de un script determinista
> commiteado, y el CI lo regenera y **falla si difiere**.

Si un valor no sobrevive a `make data && git diff --exit-code`, no es real.

## Códigos de salida de `audit.sh`

- `0` — limpio
- `1` — errores (CI que traga fallos, o un repo **con código** sin tests) → debe romper el CI
- `2` — invocación incorrecta (la ruta no es un repo git)

El chequeo de tests solo aplica si el repo tiene código de aplicación
(py/js/ts/go/rs/…). En sitios estáticos o repos de solo scripts se salta con
una nota, para no generar falsos positivos.

Los "ficheros de resultados sin generador" se reportan como *warning*
(heurístico, puede tener falsos positivos) y no rompen el build.

## Licencia

MIT — ver [`LICENSE`](LICENSE).
