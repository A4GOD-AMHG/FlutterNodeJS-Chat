# FlutterNodeJS-Chat

Aplicación móvil de chat en tiempo real desarrollada por **Alexis Manuel Hurtado Garcia** durante una práctica laboral para la Universidad de Cienfuegos. Permite registrarse, ver qué usuarios están conectados e intercambiar mensajes en tiempo real, con la posibilidad de editar y eliminar los mensajes propios gracias a Socket.io. Requiere el backend [FlutterNodeJS-Chat-Server](https://github.com/A4GOD-AMHG/FlutterNodeJS-Chat-Server).

## Tech Stack

<div style="display: flex; align-items: center;">
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/flutter/flutter-original.svg" alt="flutter" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/dart/dart-original.svg" alt="dart" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/socketio/socketio-original.svg" alt="socketio" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/nodejs/nodejs-original.svg" alt="nodejs" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/mongodb/mongodb-original.svg" alt="mongodb" width="65" height="65" />
</div>

## Características

- **Autenticación**: registro, inicio de sesión y renovación automática del token JWT, guardado en almacenamiento seguro.
- **Lista de usuarios**: estado en línea, último mensaje de cada conversación y pull-to-refresh.
- **Chat en tiempo real**: envío y recepción instantánea de mensajes con Socket.io.
- **Editar y eliminar**: mantén pulsado un mensaje propio para editarlo o borrarlo; el otro usuario lo ve al momento.
- **Interfaz moderna**: Material 3, tema claro y oscuro, burbujas con hora, avatares con iniciales y estados de carga/vacío.

## Dependencias

### Dependencias Principales

- `provider`: gestión de estado e inyección de servicios.
- `http`: peticiones REST al servidor.
- `socket_io_client`: conexión en tiempo real con el servidor.
- `flutter_secure_storage`: almacenamiento seguro del token.
- `cupertino_icons`: iconos de estilo iOS.

### Dependencias de Desarrollo

- `flutter_lints`: reglas de análisis estático recomendadas.
- `flutter_launcher_icons`: generación de los iconos de la app.

## Cómo usar

```bash
git clone https://github.com/A4GOD-AMHG/FlutterNodeJS-Chat.git
cd FlutterNodeJS-Chat
flutter pub get
flutter run
```

Por defecto la app se conecta a `http://10.0.2.2:3000` en el emulador de Android y a `http://localhost:3000` en el resto de plataformas. Para usar otro servidor:

```bash
flutter run --dart-define=SERVER_URL=https://mi-servidor.com
flutter build apk --dart-define=SERVER_URL=https://mi-servidor.com
```

## Estructura del Proyecto

```
lib/
├── global/environment.dart   # URL del servidor (configurable con --dart-define)
├── helpers/show_alert.dart   # Diálogo de alerta adaptativo
├── models/                   # Modelos User, Message y respuestas de la API
├── pages/                    # Loading, Login, Register, Users y Chat
├── routes/routes.dart        # Rutas con nombre de la app
├── services/                 # Auth, Chat, Users y Socket (Provider)
├── theme/app_theme.dart      # Tema Material 3 claro y oscuro
├── widgets/                  # Burbuja de chat, avatar, inputs y layout de auth
└── main.dart                 # Punto de entrada y proveedores
assets/                       # Logos de la app
test/widget_test.dart         # Pruebas de widgets
```

## Licencia

Este proyecto es de uso libre con fines educativos.

## Autor

**Alexis Manuel Hurtado Garcia** - [GitHub](https://github.com/A4GOD-AMHG)
