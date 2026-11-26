# Manos Unidas

Aplicación Flutter para conectar donantes con campañas y puntos de ayuda.

## Funcionalidades

- Registro e inicio de sesión.
- Campañas urgentes y frecuentes, filtros por categoría y registro de aportes.
- Perfil con total donado e historial de aportes.
- Mapa interactivo de refugios y centros de donación con OpenStreetMap.
- Datos de demostración en memoria: no se usa ninguna base de datos ni se guarda información después de cerrar la app.

Las cuentas se crean solo durante la sesión actual. Campañas, donaciones y refugios usan datos de demostración en memoria y se reinician al cerrar la app. El mapa requiere conexión a internet para cargar OpenStreetMap.

## Ejecutar en Android Studio

1. Abre la carpeta del proyecto desde Android Studio con el complemento Flutter instalado.
2. Ejecuta `flutter pub get` para instalar las dependencias.
3. Selecciona un emulador o dispositivo Android y ejecuta `flutter run`.

Las pruebas de interfaz se ejecutan con `flutter test`.
