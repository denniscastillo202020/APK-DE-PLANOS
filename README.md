# PLANOS CASTILLO

Editor rápido de planos 2D por capas, con vista de esqueleto estructural
(armado de hierro sin concreto), para anteproyectos — no es un CAD/BIM
completo.

## ⚠️ Paso obligatorio antes de compilar (no lo salgas a Codemagic sin esto)

Este entregable trae `lib/`, `pubspec.yaml`, `codemagic.yaml` y `.gitignore`,
pero **le falta la carpeta `android/`** — Flutter la genera automáticamente
y no se puede escribir a mano de forma confiable. Tienes que generarla tú
una vez, en Termux, así:

```bash
cd ~/planos-castillo   # la carpeta de tu repo ya clonado

# 1. Guarda aparte lo que ya copiamos (lib, pubspec.yaml, codemagic.yaml)
mkdir /sdcard/Download/planos_castillo_codigo
cp -r lib pubspec.yaml codemagic.yaml README.md .gitignore /sdcard/Download/planos_castillo_codigo/

# 2. Deja que Flutter genere el proyecto base completo (esto SÍ necesita
#    Flutter instalado — si no lo tienes en Termux, hazlo en Codemagic:
#    ver la alternativa más abajo)
flutter create --org com.castillo --project-name planos_castillo .

# 3. Vuelve a copiar nuestro código encima (pisa el main.dart de ejemplo)
cp -r /sdcard/Download/planos_castillo_codigo/lib .
cp /sdcard/Download/planos_castillo_codigo/pubspec.yaml .
```

**Si no tienes Flutter instalado en Termux** (lo más probable, como con
[[structia]]): sube el proyecto tal cual está (sin `android/`) a GitHub
primero, y en Codemagic, en el paso de configuración inicial, selecciona
la opción "Flutter App" — Codemagic detecta que falta `android/` y en
varios casos lo genera solo al primer build. Si el build falla pidiendo
`android/`, avísame y armamos la carpeta a mano archivo por archivo
(es más tedioso pero se puede).

## Subir a GitHub

```bash
cd ~/planos-castillo
git add .
git commit -m "Primera versión: editor 2D por capas con vista de esqueleto"
git push
```

## Qué hace esta primera versión

- Lienzo con cuadrícula donde arrastras el dedo para colocar: muro,
  columna, viga, losa, techo, puerta, ventana (barra inferior).
- Panel de capas (ícono de capas en la barra superior): apaga/enciende
  Muros, Estructura, Techos, Vanos por separado.
- Botón de ojo en la barra superior: **interruptor global de esqueleto**
  — oculta el concreto de columnas/vigas/losas y deja solo las varillas
  dibujadas, de toda la estructura conectada a la vez.
- Cada columna/viga ya trae un armado de varillas por defecto (plantilla
  estándar); editarlo a mano se agrega en la siguiente iteración.

## Pendiente para siguientes iteraciones

- Guardar/cargar el plano (persistencia local).
- Editar el armado de una columna/viga ya colocada (tocarla y abrir un
  formulario).
- Snapping de muros a la cuadrícula y entre sí.
- Conectar con [[structia]]: que un muro dibujado aquí alimente
  directamente la calculadora de mampostería.
