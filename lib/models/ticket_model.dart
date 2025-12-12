/// Modelo de Vehículo
class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String plates;
  final String? internalCode;
  final String? color;
  final String? vehicleType;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plates,
    this.internalCode,
    this.color,
    this.vehicleType,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      plates: json['plates']?.toString() ?? '',
      internalCode: json['internal_code']?.toString(),
      color: json['color']?.toString(),
      vehicleType: json['vehicle_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'plates': plates,
      'internal_code': internalCode,
      'color': color,
      'vehicle_type': vehicleType,
    };
  }
}

/// Modelo de Licencia de Conductor
class ConductorLicenseModel {
  final int id;
  final String licenseNumber;
  final String? licenseType;
  final String fullName;
  final DateTime? expiryDate;

  ConductorLicenseModel({
    required this.id,
    required this.licenseNumber,
    this.licenseType,
    required this.fullName,
    this.expiryDate,
  });

  factory ConductorLicenseModel.fromJson(Map<String, dynamic> json) {
    return ConductorLicenseModel(
      id: json['id'] as int,
      licenseNumber: json['license_number']?.toString() ?? '',
      licenseType: json['license_type']?.toString(),
      fullName: json['full_name']?.toString() ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date']?.toString() ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_number': licenseNumber,
      'license_type': licenseType,
      'full_name': fullName,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}

/// Modelo de Ticket con relaciones
class TicketModel {
  final int id;
  final String folio;
  final String? requisicion;
  final String status;
  final String? destination;
  final String? cliente;
  final String? purpose;
  final int? passengerCount;
  final String? additionalNotes;
  final DateTime? requestedDate;
  final String? requestedTimeStart;
  final String? requestedTimeEnd;
  final String? conductorName;
  final String? conductorPhone;
  final DateTime? approvedAt;
  final DateTime? checkoutAt;
  final DateTime? checkinAt;
  final DateTime? completedAt;

  // Relaciones
  final Map<String, dynamic>? user;
  final VehicleModel? vehicle;
  final ConductorLicenseModel? conductorLicense;
  final ChecklistResponseModel? checkoutChecklist;
  final ChecklistResponseModel? checkinChecklist;

  TicketModel({
    required this.id,
    required this.folio,
    this.requisicion,
    required this.status,
    this.destination,
    this.cliente,
    this.purpose,
    this.passengerCount,
    this.additionalNotes,
    this.requestedDate,
    this.requestedTimeStart,
    this.requestedTimeEnd,
    this.conductorName,
    this.conductorPhone,
    this.approvedAt,
    this.checkoutAt,
    this.checkinAt,
    this.completedAt,
    this.user,
    this.vehicle,
    this.conductorLicense,
    this.checkoutChecklist,
    this.checkinChecklist,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      folio: json['folio']?.toString() ?? '',
      requisicion: json['requisicion']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      destination: json['destination']?.toString(),
      cliente: json['cliente']?.toString(),
      purpose: json['purpose']?.toString(),
      passengerCount: json['passenger_count'] != null ? int.tryParse(json['passenger_count']?.toString() ?? '') : null,
      additionalNotes: json['additional_notes']?.toString(),
      requestedDate: json['requested_date'] != null
          ? DateTime.tryParse(json['requested_date']?.toString() ?? '')
          : null,
      requestedTimeStart: json['requested_time_start']?.toString(),
      requestedTimeEnd: json['requested_time_end']?.toString(),
      conductorName: json['conductor_name']?.toString(),
      conductorPhone: json['conductor_phone']?.toString(),
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at']?.toString() ?? '')
          : null,
      checkoutAt: json['checkout_at'] != null
          ? DateTime.tryParse(json['checkout_at']?.toString() ?? '')
          : null,
      checkinAt: json['checkin_at'] != null
          ? DateTime.tryParse(json['checkin_at']?.toString() ?? '')
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at']?.toString() ?? '')
          : null,
      user: json['user'] as Map<String, dynamic>?,
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      conductorLicense: json['conductor_license'] != null
          ? ConductorLicenseModel.fromJson(
              json['conductor_license'] as Map<String, dynamic>)
          : null,
      checkoutChecklist: json['checkout_checklist'] != null
          ? ChecklistResponseModel.fromJson(
              json['checkout_checklist'] as Map<String, dynamic>)
          : null,
      checkinChecklist: json['checkin_checklist'] != null
          ? ChecklistResponseModel.fromJson(
              json['checkin_checklist'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folio': folio,
      'requisicion': requisicion,
      'status': status,
      'destination': destination,
      'cliente': cliente,
      'purpose': purpose,
      'passenger_count': passengerCount,
      'additional_notes': additionalNotes,
      'requested_date': requestedDate?.toIso8601String(),
      'requested_time_start': requestedTimeStart,
      'requested_time_end': requestedTimeEnd,
      'conductor_name': conductorName,
      'conductor_phone': conductorPhone,
      'approved_at': approvedAt?.toIso8601String(),
      'checkout_at': checkoutAt?.toIso8601String(),
      'checkin_at': checkinAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'user': user,
      'vehicle': vehicle?.toJson(),
      'conductor_license': conductorLicense?.toJson(),
      'checkout_checklist': checkoutChecklist?.toJson(),
      'checkin_checklist': checkinChecklist?.toJson(),
    };
  }

  /// Helper para verificar si el ticket tiene checkout realizado
  bool get hasCheckout => checkoutChecklist?.exists ?? false;

  /// Helper para verificar si el ticket tiene checkin realizado
  bool get hasCheckin => checkinChecklist?.exists ?? false;

  /// Helper para obtener el nombre del vehículo
  String get vehicleName {
    if (vehicle == null) return 'Sin vehículo';
    return '${vehicle!.brand} ${vehicle!.model} (${vehicle!.plates})';
  }
}

/// Modelo de respuesta de Checklist desde la API
class ChecklistResponseModel {
  final int? id;
  final bool exists;
  final String tipoInspeccion;
  final String folio;
  final DateTime? fecha;
  final String? destino;
  final String? modelo;
  final String? placas;
  final String? marca;
  final String? horaSalida;
  final String? horaEntrada;
  final double? kilometrajeInicial;
  final double? kilometrajeFinal;
  final String? nivelCombustibleInicial;
  final String? nivelCombustibleFinal;

  // Secciones organizadas
  final Map<String, dynamic>? llantas;
  final Map<String, dynamic>? frontal;
  final Map<String, dynamic>? luces;
  final Map<String, dynamic>? seguridad;
  final Map<String, dynamic>? interior;
  final Map<String, dynamic>? motor;
  final Map<String, dynamic>? herramienta;
  final Map<String, dynamic>? calcomanias;
  final Map<String, dynamic>? observaciones;

  ChecklistResponseModel({
    this.id,
    required this.exists,
    required this.tipoInspeccion,
    required this.folio,
    this.fecha,
    this.destino,
    this.modelo,
    this.placas,
    this.marca,
    this.horaSalida,
    this.horaEntrada,
    this.kilometrajeInicial,
    this.kilometrajeFinal,
    this.nivelCombustibleInicial,
    this.nivelCombustibleFinal,
    this.llantas,
    this.frontal,
    this.luces,
    this.seguridad,
    this.interior,
    this.motor,
    this.herramienta,
    this.calcomanias,
    this.observaciones,
  });

  factory ChecklistResponseModel.fromJson(Map<String, dynamic> json) {
    return ChecklistResponseModel(
      id: json['id'] as int?,
      exists: json['exists'] as bool? ?? false,
      tipoInspeccion: json['tipo_inspeccion']?.toString() ?? '',
      folio: json['folio']?.toString() ?? '',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']?.toString() ?? '') : null,
      destino: json['destino']?.toString(),
      modelo: json['modelo']?.toString(),
      placas: json['placas']?.toString(),
      marca: json['marca']?.toString(),
      horaSalida: json['hora_salida']?.toString(),
      horaEntrada: json['hora_entrada']?.toString(),
      kilometrajeInicial: json['kilometraje_inicial'] != null
          ? double.tryParse(json['kilometraje_inicial']?.toString() ?? '')
          : null,
      kilometrajeFinal: json['kilometraje_final'] != null
          ? double.tryParse(json['kilometraje_final']?.toString() ?? '')
          : null,
      nivelCombustibleInicial: json['nivel_combustible_inicial']?.toString(),
      nivelCombustibleFinal: json['nivel_combustible_final']?.toString(),
      llantas: json['llantas'] as Map<String, dynamic>?,
      frontal: json['frontal'] as Map<String, dynamic>?,
      luces: json['luces'] as Map<String, dynamic>?,
      seguridad: json['seguridad'] as Map<String, dynamic>?,
      interior: json['interior'] as Map<String, dynamic>?,
      motor: json['motor'] as Map<String, dynamic>?,
      herramienta: json['herramienta'] as Map<String, dynamic>?,
      calcomanias: json['calcomanias'] as Map<String, dynamic>?,
      observaciones: json['observaciones'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exists': exists,
      'tipo_inspeccion': tipoInspeccion,
      'folio': folio,
      'fecha': fecha?.toIso8601String(),
      'destino': destino,
      'modelo': modelo,
      'placas': placas,
      'marca': marca,
      'hora_salida': horaSalida,
      'hora_entrada': horaEntrada,
      'kilometraje_inicial': kilometrajeInicial,
      'kilometraje_final': kilometrajeFinal,
      'nivel_combustible_inicial': nivelCombustibleInicial,
      'nivel_combustible_final': nivelCombustibleFinal,
      'llantas': llantas,
      'frontal': frontal,
      'luces': luces,
      'seguridad': seguridad,
      'interior': interior,
      'motor': motor,
      'herramienta': herramienta,
      'calcomanias': calcomanias,
      'observaciones': observaciones,
    };
  }
}
