# Documentación API - Checkin y Checkout

## Resumen

Los servicios de checkin y checkout están separados en archivos independientes para mejor organización y mantenibilidad.

## Estructura de Servicios

### 📁 Archivos Principales

```
lib/
├── models/
│   └── api_response.dart          # Modelos de respuesta (ApiResponse, ChecklistSubmitResponse)
├── services/
│   ├── checkin_service.dart       # Servicio exclusivo para check-in
│   ├── checkout_service.dart      # Servicio exclusivo para check-out
│   ├── api_service.dart           # Servicio general (login, etc.)
│   └── storage_service.dart       # Almacenamiento local
└── screens/
    └── tickets/
        ├── checkin_screen.dart    # Usa CheckinService
        └── checkout_screen_new.dart  # Usa CheckoutService
```

## CheckinService

### 📋 Características

**Ubicación**: `lib/services/checkin_service.dart`

**Patrón**: Singleton

**Métodos disponibles**:

#### 1. `submitCheckin()`
Envía el checklist de entrada al backend

```dart
Future<ApiResponse<ChecklistSubmitResponse>> submitCheckin({
  required int ticketId,
  required Map<String, dynamic> checklistData,
})
```

**Uso**:
```dart
final checkinService = CheckinService();
final response = await checkinService.submitCheckin(
  ticketId: 123,
  checklistData: checklistModel.toJson(),
);
```

#### 2. `getCheckin()`
Obtiene un checklist de entrada existente

```dart
Future<ApiResponse<Map<String, dynamic>?>> getCheckin({
  required int ticketId,
})
```

#### 3. `validateCheckin()`
Valida si se puede realizar un checkin para un ticket

```dart
Future<ApiResponse<bool>> validateCheckin({
  required int ticketId,
})
```

## CheckoutService

### 📋 Características

**Ubicación**: `lib/services/checkout_service.dart`

**Patrón**: Singleton

**Métodos disponibles**:

#### 1. `submitCheckout()`
Envía el checklist de salida al backend

```dart
Future<ApiResponse<ChecklistSubmitResponse>> submitCheckout({
  required int ticketId,
  required Map<String, dynamic> checklistData,
})
```

**Uso**:
```dart
final checkoutService = CheckoutService();
final response = await checkoutService.submitCheckout(
  ticketId: 123,
  checklistData: checklistModel.toJson(),
);
```

#### 2. `getCheckout()`
Obtiene un checklist de salida existente

```dart
Future<ApiResponse<Map<String, dynamic>?>> getCheckout({
  required int ticketId,
})
```

## Modelos de Respuesta

### ApiResponse<T>

Ubicado en `lib/models/api_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
}
```

**Constructores helper**:
- `ApiResponse.success()` - Respuesta exitosa
- `ApiResponse.error()` - Respuesta de error

### ChecklistSubmitResponse

```dart
class ChecklistSubmitResponse {
  final Map<String, dynamic> checklist;
  final TicketModel ticket;
}
```

## Endpoints

```
POST   /api/dispatcher/checklist/checkout   # Enviar checkout
GET    /api/dispatcher/checklist/checkout/:id  # Obtener checkout

POST   /api/dispatcher/checklist/checkin    # Enviar checkin
GET    /api/dispatcher/checklist/checkin/:id   # Obtener checkin
GET    /api/dispatcher/checklist/checkin/validate/:id  # Validar checkin
```

## Ejemplo de Uso Completo

### Checkin

```dart
import '../../services/checkin_service.dart';
import '../../services/storage_service.dart';

class CheckinScreen extends StatefulWidget {
  // ...
}

class _CheckinScreenState extends State<CheckinScreen> {
  final CheckinService _checkinService = CheckinService();
  final StorageService _storageService = StorageService();

  Future<void> _submit() async {
    try {
      // Construir modelo
      final checklistCompleto = ChecklistModel(
        // ... datos del checklist
      );

      // Enviar al backend
      final response = await _checkinService.submitCheckin(
        ticketId: widget.ticket.id,
        checklistData: checklistCompleto.toJson(),
      );

      if (response.success) {
        // Actualizar storage local
        if (response.data?.ticket != null) {
          await _storageService.updateTicket(response.data!.ticket);
        }

        // Mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        // Manejar errores
        String errorMsg = response.message;
        if (response.errors != null) {
          errorMsg += '\n\n${response.errors!.values.join('\n')}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejar excepciones
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

## Payload de Checkin

```json
{
  "ticket_id": 123,
  "tipo_inspeccion": "entrada",
  "folio": "ABC123",
  "fecha": "2025-12-15",
  "destino": "Ciudad de México",
  "modelo": "2023",
  "placas": "ABC-123",
  "marca": "Toyota",
  "hora_entrada": "14:30",
  "kilometraje_final": 15000.0,
  "nivel_combustible_final": "3/4",
  
  // Más de 60 campos booleanos
  "llanta_delantera_derecha_ok": true,
  "llanta_delantera_izquierda_ok": true,
  // ...
  
  "condicion_carroceria_imagen": "base64_string_or_null"
}
```

## Respuestas del Backend

### Éxito (200)
```json
{
  "success": true,
  "message": "Checklist guardado correctamente",
  "data": {
    "checklist": { /* ChecklistModel */ },
    "ticket": { /* TicketModel actualizado */ }
  }
}
```

### Error de Validación (422)
```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "kilometraje_final": ["El kilometraje es requerido"],
    "nivel_combustible_final": ["Valor inválido"]
  }
}
```

### Error del Servidor (500)
```json
{
  "success": false,
  "message": "Error interno del servidor"
}
```

## Manejo de Imágenes

Las imágenes se envían como strings base64 en el campo `condicion_carroceria_imagen`.

### Consideraciones:
- ✅ Conversión a base64 implementada
- ⚠️ Puede ser pesado para imágenes grandes
- 💡 Considerar compresión antes de enviar
- 💡 Alternativa: usar multipart/form-data

## Testing

### Checklist de Pruebas

- [x] Compilación sin errores
- [ ] Envío exitoso de checkin
- [ ] Envío exitoso de checkout
- [ ] Manejo de errores de red
- [ ] Validación del backend (422)
- [ ] Actualización de ticket local
- [ ] Prueba con imágenes grandes

## Ventajas de Servicios Separados

1. **Organización**: Cada servicio tiene su responsabilidad única
2. **Mantenibilidad**: Cambios en checkin no afectan checkout
3. **Testabilidad**: Más fácil crear mocks y tests unitarios
4. **Escalabilidad**: Fácil agregar nuevos métodos específicos
5. **Legibilidad**: Código más limpio y fácil de entender

## Migración

Si tienes código antiguo usando `ApiService`, simplemente cambia:

```dart
// Antes
final _apiService = ApiService();
final response = await _apiService.submitCheckin(...);

// Ahora
final _checkinService = CheckinService();
final response = await _checkinService.submitCheckin(...);
```

## Notas Importantes

1. Ambos servicios usan el patrón Singleton
2. Los logs se manejan automáticamente con LogService
3. Timeouts configurados en ApiConfig (30 segundos)
4. Headers JSON automáticos
5. Manejo de errores consistente en todos los métodos
