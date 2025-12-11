# GPT Tickets Autos 🚗

Aplicación Flutter para gestión de tickets de vehículos con autenticación por Google Sign-In.

## 🚀 Características

- ✅ Autenticación con Google Sign-In
- ✅ Persistencia de sesión (silent sign-in)
- ✅ UI moderna y responsiva
- ✅ Multi-plataforma (Android, iOS, Web)

## 📋 Pre-requisitos

- Flutter SDK (>= 3.9.2)
- Cuenta de Auth0 (gratuita)
- Proyecto de Google Cloud (para Google Sign-In)

## 🔧 Configuración rápida

1) Instalar dependencias

```bash
flutter pub get
```

2) Crear OAuth client Android en Google Cloud

- Application type: Android
- Package name (applicationId): `com.gptservices.autos`
- SHA1 debug: la que generamos (ver abajo)
- Usa el Client ID que obtuviste: `584000134985-auc0bsbpq7c6227hocv3utoi30flmikl.apps.googleusercontent.com`

3) (Opcional iOS) Crear OAuth client iOS y añade el reversed client id al `Info.plist`.

4) Ejecutar la aplicación

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## 📁 Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada y AuthWrapper
├── services/
│   └── auth_service.dart       # Servicio de autenticación Google Sign-In
└── screens/
    ├── login_screen.dart       # Pantalla de login
    └── home_screen.dart        # Pantalla principal
```

## 🛠️ Tecnologías

- **Flutter** - Framework de UI
- **Google Sign-In** - Autenticación

## 📱 Plataformas soportadas

- ✅ Android (minSdk 21+)
- ✅ iOS (11.0+)
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📚 Documentación adicional

- [Documentación de Flutter](https://docs.flutter.dev/)
- [google_sign_in package](https://pub.dev/packages/google_sign_in)

## 🔐 Seguridad

- No subas tus client secrets a Git.
- Usa keystores distintos para debug y release.

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

## ✨ Autor

Tu nombre - [@tu_twitter](https://twitter.com/tu_twitter)

## 🐛 Issues

Si encuentras algún problema, por favor abre un issue en GitHub.
