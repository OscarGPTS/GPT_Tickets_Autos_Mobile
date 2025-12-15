class ChecklistModel {
  final int? id;
  final int ticketId;
  final String tipoInspeccion; // 'salida' o 'entrada'
  final String folio;
  final String fecha;
  final String destino;
  final String modelo;
  final String placas;
  final String marca;

  // Tiempos y kilometraje
  final String? horaSalida;
  final String? horaEntrada;
  final double kilometrajeInicial;
  final double? kilometrajeFinal;
  final String nivelCombustibleInicial;
  final String? nivelCombustibleFinal;

  // Llantas
  final bool llantaDelanteraDerechaOk;
  final bool llantaDelanteraIzquierdaOk;
  final bool llantaDelanteraVidaOk;
  final bool llantaTrseraDerechaOk;
  final bool llantaTraseraIzquierdaOk;
  final bool llantaTraseraVidaOk;
  final bool llantaRefaccionOk;
  final bool presionAdecuadaOk;

  // Frontal
  final bool parabrisisOk;
  final bool cofreOk;
  final bool parrillaOk;
  final bool defensasOk;
  final bool moldurasOk;
  final bool placaOk;
  final bool salpicaderaOk;
  final bool antenaOk;

  // Luces
  final bool intermitentesOk;
  final bool direccionalDerechaOk;
  final bool direccionalIzquierdaOk;
  final bool luzStopOk;
  final bool farosOk;
  final bool lucesAltasOk;
  final bool luzInteriorOk;
  final bool calaveras;

  // Seguridad
  final bool mataChispassOk;
  final bool alarmaOk;
  final bool extintorOk;
  final bool botiquinOk;
  final bool tarjetaCirculacionOk;
  final bool licenciaConducirVigenteOk;
  final bool polizaSeguroOk;
  final bool trianguloEmergenciaOk;

  // Interior
  final bool tableroIndicadoresOk;
  final bool switchEncendidoOk;
  final bool controlesAcOk;
  final bool defrosterOk;
  final bool radioOk;
  final bool volanteOk;
  final bool bolsasAireOk;
  final bool cinturonSeguridadOk;
  final bool coderasOk;
  final bool espejoInteriorOk;
  final bool frenoManoOk;
  final bool encendedorOk;
  final bool guanteraOk;
  final bool manijasInterioresOk;
  final bool segurosOk;
  final bool asientosOk;
  final bool tapetesOk;

  // Motor
  final bool nivelAceiteMotorOk;
  final bool nivelAnticongelanteOk;
  final bool nivelLiquidoFrenosOk;
  final bool bateriaOk;
  final bool bayonetaAceiteOk;
  final bool taponesOk;
  final bool bocinaClaxxonOk;
  final bool radiadorOk;

  // Herramientas
  final bool gatoOk;
  final bool llaveLlantasOk;
  final bool cablesPasaCorrienteOk;
  final bool cajaHerramientasOk;
  final bool dadoBirloSeguidadOk;

  // Calcomanías
  final bool calcomaniastPermisosOk;
  final bool calcomaniaVelocidadMaximaOk;

  // Observaciones
  final String? mantenimientoPreventivo;
  final String? mantenimientoCorrectivo;
  final String? condicionCarroceriaLog;
  final String? condicionCarroceriaImagen; // Base64 de imagen con daños dibujados
  final String? responsableReciboUso;
  final String? responsableEntrega;

  ChecklistModel({
    this.id,
    required this.ticketId,
    required this.tipoInspeccion,
    required this.folio,
    required this.fecha,
    required this.destino,
    required this.modelo,
    required this.placas,
    required this.marca,
    this.horaSalida,
    this.horaEntrada,
    required this.kilometrajeInicial,
    this.kilometrajeFinal,
    required this.nivelCombustibleInicial,
    this.nivelCombustibleFinal,
    this.llantaDelanteraDerechaOk = true,
    this.llantaDelanteraIzquierdaOk = true,
    this.llantaDelanteraVidaOk = true,
    this.llantaTrseraDerechaOk = true,
    this.llantaTraseraIzquierdaOk = true,
    this.llantaTraseraVidaOk = true,
    this.llantaRefaccionOk = true,
    this.presionAdecuadaOk = true,
    this.parabrisisOk = true,
    this.cofreOk = true,
    this.parrillaOk = true,
    this.defensasOk = true,
    this.moldurasOk = true,
    this.placaOk = true,
    this.salpicaderaOk = true,
    this.antenaOk = true,
    this.intermitentesOk = true,
    this.direccionalDerechaOk = true,
    this.direccionalIzquierdaOk = true,
    this.luzStopOk = true,
    this.farosOk = true,
    this.lucesAltasOk = true,
    this.luzInteriorOk = true,
    this.calaveras = true,
    this.mataChispassOk = true,
    this.alarmaOk = true,
    this.extintorOk = true,
    this.botiquinOk = true,
    this.tarjetaCirculacionOk = true,
    this.licenciaConducirVigenteOk = true,
    this.polizaSeguroOk = true,
    this.trianguloEmergenciaOk = true,
    this.tableroIndicadoresOk = true,
    this.switchEncendidoOk = true,
    this.controlesAcOk = true,
    this.defrosterOk = true,
    this.radioOk = true,
    this.volanteOk = true,
    this.bolsasAireOk = true,
    this.cinturonSeguridadOk = true,
    this.coderasOk = true,
    this.espejoInteriorOk = true,
    this.frenoManoOk = true,
    this.encendedorOk = true,
    this.guanteraOk = true,
    this.manijasInterioresOk = true,
    this.segurosOk = true,
    this.asientosOk = true,
    this.tapetesOk = true,
    this.nivelAceiteMotorOk = true,
    this.nivelAnticongelanteOk = true,
    this.nivelLiquidoFrenosOk = true,
    this.bateriaOk = true,
    this.bayonetaAceiteOk = true,
    this.taponesOk = true,
    this.bocinaClaxxonOk = true,
    this.radiadorOk = true,
    this.gatoOk = true,
    this.llaveLlantasOk = true,
    this.cablesPasaCorrienteOk = true,
    this.cajaHerramientasOk = true,
    this.dadoBirloSeguidadOk = true,
    this.calcomaniastPermisosOk = true,
    this.calcomaniaVelocidadMaximaOk = true,
    this.mantenimientoPreventivo,
    this.mantenimientoCorrectivo,
    this.condicionCarroceriaLog,
    this.condicionCarroceriaImagen,
    this.responsableReciboUso,
    this.responsableEntrega,
  });

  /// Crea una copia del ChecklistModel con los campos especificados reemplazados
  ChecklistModel copyWith({
    int? id,
    int? ticketId,
    String? tipoInspeccion,
    String? folio,
    String? fecha,
    String? destino,
    String? modelo,
    String? placas,
    String? marca,
    String? horaSalida,
    String? horaEntrada,
    double? kilometrajeInicial,
    double? kilometrajeFinal,
    String? nivelCombustibleInicial,
    String? nivelCombustibleFinal,
    bool? llantaDelanteraDerechaOk,
    bool? llantaDelanteraIzquierdaOk,
    bool? llantaDelanteraVidaOk,
    bool? llantaTrseraDerechaOk,
    bool? llantaTraseraIzquierdaOk,
    bool? llantaTraseraVidaOk,
    bool? llantaRefaccionOk,
    bool? presionAdecuadaOk,
    bool? parabrisisOk,
    bool? cofreOk,
    bool? parrillaOk,
    bool? defensasOk,
    bool? moldurasOk,
    bool? placaOk,
    bool? salpicaderaOk,
    bool? antenaOk,
    bool? intermitentesOk,
    bool? direccionalDerechaOk,
    bool? direccionalIzquierdaOk,
    bool? luzStopOk,
    bool? farosOk,
    bool? lucesAltasOk,
    bool? luzInteriorOk,
    bool? calaveras,
    bool? mataChispassOk,
    bool? alarmaOk,
    bool? extintorOk,
    bool? botiquinOk,
    bool? tarjetaCirculacionOk,
    bool? licenciaConducirVigenteOk,
    bool? polizaSeguroOk,
    bool? trianguloEmergenciaOk,
    bool? tableroIndicadoresOk,
    bool? switchEncendidoOk,
    bool? controlesAcOk,
    bool? defrosterOk,
    bool? radioOk,
    bool? volanteOk,
    bool? bolsasAireOk,
    bool? cinturonSeguridadOk,
    bool? coderasOk,
    bool? espejoInteriorOk,
    bool? frenoManoOk,
    bool? encendedorOk,
    bool? guanteraOk,
    bool? manijasInterioresOk,
    bool? segurosOk,
    bool? asientosOk,
    bool? tapetesOk,
    bool? nivelAceiteMotorOk,
    bool? nivelAnticongelanteOk,
    bool? nivelLiquidoFrenosOk,
    bool? bateriaOk,
    bool? bayonetaAceiteOk,
    bool? taponesOk,
    bool? bocinaClaxxonOk,
    bool? radiadorOk,
    bool? gatoOk,
    bool? llaveLlantasOk,
    bool? cablesPasaCorrienteOk,
    bool? cajaHerramientasOk,
    bool? dadoBirloSeguidadOk,
    bool? calcomaniastPermisosOk,
    bool? calcomaniaVelocidadMaximaOk,
    String? mantenimientoPreventivo,
    String? mantenimientoCorrectivo,
    String? condicionCarroceriaLog,
    String? condicionCarroceriaImagen,
    String? responsableReciboUso,
    String? responsableEntrega,
  }) {
    return ChecklistModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      tipoInspeccion: tipoInspeccion ?? this.tipoInspeccion,
      folio: folio ?? this.folio,
      fecha: fecha ?? this.fecha,
      destino: destino ?? this.destino,
      modelo: modelo ?? this.modelo,
      placas: placas ?? this.placas,
      marca: marca ?? this.marca,
      horaSalida: horaSalida ?? this.horaSalida,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      kilometrajeInicial: kilometrajeInicial ?? this.kilometrajeInicial,
      kilometrajeFinal: kilometrajeFinal ?? this.kilometrajeFinal,
      nivelCombustibleInicial: nivelCombustibleInicial ?? this.nivelCombustibleInicial,
      nivelCombustibleFinal: nivelCombustibleFinal ?? this.nivelCombustibleFinal,
      llantaDelanteraDerechaOk: llantaDelanteraDerechaOk ?? this.llantaDelanteraDerechaOk,
      llantaDelanteraIzquierdaOk: llantaDelanteraIzquierdaOk ?? this.llantaDelanteraIzquierdaOk,
      llantaDelanteraVidaOk: llantaDelanteraVidaOk ?? this.llantaDelanteraVidaOk,
      llantaTrseraDerechaOk: llantaTrseraDerechaOk ?? this.llantaTrseraDerechaOk,
      llantaTraseraIzquierdaOk: llantaTraseraIzquierdaOk ?? this.llantaTraseraIzquierdaOk,
      llantaTraseraVidaOk: llantaTraseraVidaOk ?? this.llantaTraseraVidaOk,
      llantaRefaccionOk: llantaRefaccionOk ?? this.llantaRefaccionOk,
      presionAdecuadaOk: presionAdecuadaOk ?? this.presionAdecuadaOk,
      parabrisisOk: parabrisisOk ?? this.parabrisisOk,
      cofreOk: cofreOk ?? this.cofreOk,
      parrillaOk: parrillaOk ?? this.parrillaOk,
      defensasOk: defensasOk ?? this.defensasOk,
      moldurasOk: moldurasOk ?? this.moldurasOk,
      placaOk: placaOk ?? this.placaOk,
      salpicaderaOk: salpicaderaOk ?? this.salpicaderaOk,
      antenaOk: antenaOk ?? this.antenaOk,
      intermitentesOk: intermitentesOk ?? this.intermitentesOk,
      direccionalDerechaOk: direccionalDerechaOk ?? this.direccionalDerechaOk,
      direccionalIzquierdaOk: direccionalIzquierdaOk ?? this.direccionalIzquierdaOk,
      luzStopOk: luzStopOk ?? this.luzStopOk,
      farosOk: farosOk ?? this.farosOk,
      lucesAltasOk: lucesAltasOk ?? this.lucesAltasOk,
      luzInteriorOk: luzInteriorOk ?? this.luzInteriorOk,
      calaveras: calaveras ?? this.calaveras,
      mataChispassOk: mataChispassOk ?? this.mataChispassOk,
      alarmaOk: alarmaOk ?? this.alarmaOk,
      extintorOk: extintorOk ?? this.extintorOk,
      botiquinOk: botiquinOk ?? this.botiquinOk,
      tarjetaCirculacionOk: tarjetaCirculacionOk ?? this.tarjetaCirculacionOk,
      licenciaConducirVigenteOk: licenciaConducirVigenteOk ?? this.licenciaConducirVigenteOk,
      polizaSeguroOk: polizaSeguroOk ?? this.polizaSeguroOk,
      trianguloEmergenciaOk: trianguloEmergenciaOk ?? this.trianguloEmergenciaOk,
      tableroIndicadoresOk: tableroIndicadoresOk ?? this.tableroIndicadoresOk,
      switchEncendidoOk: switchEncendidoOk ?? this.switchEncendidoOk,
      controlesAcOk: controlesAcOk ?? this.controlesAcOk,
      defrosterOk: defrosterOk ?? this.defrosterOk,
      radioOk: radioOk ?? this.radioOk,
      volanteOk: volanteOk ?? this.volanteOk,
      bolsasAireOk: bolsasAireOk ?? this.bolsasAireOk,
      cinturonSeguridadOk: cinturonSeguridadOk ?? this.cinturonSeguridadOk,
      coderasOk: coderasOk ?? this.coderasOk,
      espejoInteriorOk: espejoInteriorOk ?? this.espejoInteriorOk,
      frenoManoOk: frenoManoOk ?? this.frenoManoOk,
      encendedorOk: encendedorOk ?? this.encendedorOk,
      guanteraOk: guanteraOk ?? this.guanteraOk,
      manijasInterioresOk: manijasInterioresOk ?? this.manijasInterioresOk,
      segurosOk: segurosOk ?? this.segurosOk,
      asientosOk: asientosOk ?? this.asientosOk,
      tapetesOk: tapetesOk ?? this.tapetesOk,
      nivelAceiteMotorOk: nivelAceiteMotorOk ?? this.nivelAceiteMotorOk,
      nivelAnticongelanteOk: nivelAnticongelanteOk ?? this.nivelAnticongelanteOk,
      nivelLiquidoFrenosOk: nivelLiquidoFrenosOk ?? this.nivelLiquidoFrenosOk,
      bateriaOk: bateriaOk ?? this.bateriaOk,
      bayonetaAceiteOk: bayonetaAceiteOk ?? this.bayonetaAceiteOk,
      taponesOk: taponesOk ?? this.taponesOk,
      bocinaClaxxonOk: bocinaClaxxonOk ?? this.bocinaClaxxonOk,
      radiadorOk: radiadorOk ?? this.radiadorOk,
      gatoOk: gatoOk ?? this.gatoOk,
      llaveLlantasOk: llaveLlantasOk ?? this.llaveLlantasOk,
      cablesPasaCorrienteOk: cablesPasaCorrienteOk ?? this.cablesPasaCorrienteOk,
      cajaHerramientasOk: cajaHerramientasOk ?? this.cajaHerramientasOk,
      dadoBirloSeguidadOk: dadoBirloSeguidadOk ?? this.dadoBirloSeguidadOk,
      calcomaniastPermisosOk: calcomaniastPermisosOk ?? this.calcomaniastPermisosOk,
      calcomaniaVelocidadMaximaOk: calcomaniaVelocidadMaximaOk ?? this.calcomaniaVelocidadMaximaOk,
      mantenimientoPreventivo: mantenimientoPreventivo ?? this.mantenimientoPreventivo,
      mantenimientoCorrectivo: mantenimientoCorrectivo ?? this.mantenimientoCorrectivo,
      condicionCarroceriaLog: condicionCarroceriaLog ?? this.condicionCarroceriaLog,
      condicionCarroceriaImagen: condicionCarroceriaImagen ?? this.condicionCarroceriaImagen,
      responsableReciboUso: responsableReciboUso ?? this.responsableReciboUso,
      responsableEntrega: responsableEntrega ?? this.responsableEntrega,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'tipo_inspeccion': tipoInspeccion,
      'folio': folio,
      'fecha': fecha,
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
      // Llantas
      'llanta_delantera_derecha': llantaDelanteraDerechaOk,
      'llanta_delantera_izquierda': llantaDelanteraIzquierdaOk,
      'llanta_delantera_vida': llantaDelanteraVidaOk,
      'llanta_trasera_derecha': llantaTrseraDerechaOk,
      'llanta_trasera_izquierda': llantaTraseraIzquierdaOk,
      'llanta_trasera_vida': llantaTraseraVidaOk,
      'llanta_refaccion': llantaRefaccionOk,
      'presion_adecuada': presionAdecuadaOk,
      // Frontal
      'parabrisas': parabrisisOk,
      'cofre': cofreOk,
      'parrilla': parrillaOk,
      'defensas': defensasOk,
      'molduras': moldurasOk,
      'placa': placaOk,
      'salpicadera': salpicaderaOk,
      'antena': antenaOk,
      // Luces
      'intermitentes': intermitentesOk,
      'direccional_derecha': direccionalDerechaOk,
      'direccional_izquierda': direccionalIzquierdaOk,
      'luz_stop': luzStopOk,
      'faros': farosOk,
      'luces_altas': lucesAltasOk,
      'luz_interior': luzInteriorOk,
      'calaveras_buen_estado': calaveras,
      // Seguridad
      'mata_chispas': mataChispassOk,
      'alarma': alarmaOk,
      'extintor': extintorOk,
      'botiquin': botiquinOk,
      'tarjeta_circulacion': tarjetaCirculacionOk,
      'licencia_conducir_vigente': licenciaConducirVigenteOk,
      'poliza_seguro': polizaSeguroOk,
      'triangulo_emergencia': trianguloEmergenciaOk,
      // Interior
      'tablero_indicadores': tableroIndicadoresOk,
      'switch_encendido': switchEncendidoOk,
      'controles_ac': controlesAcOk,
      'defroster': defrosterOk,
      'radio': radioOk,
      'volante': volanteOk,
      'bolsas_aire': bolsasAireOk,
      'cintulon_seguridad': cinturonSeguridadOk,
      'coderas': coderasOk,
      'espejo_interior': espejoInteriorOk,
      'freno_mano': frenoManoOk,
      'encendedor': encendedorOk,
      'guantera': guanteraOk,
      'manijas_interiores': manijasInterioresOk,
      'seguros': segurosOk,
      'asientos': asientosOk,
      'tapetes_delanteros_traseros': tapetesOk,
      // Motor
      'nivel_aceite_motor': nivelAceiteMotorOk,
      'nivel_anticongelante': nivelAnticongelanteOk,
      'nivel_liquido_frenos': nivelLiquidoFrenosOk,
      'bateria': bateriaOk,
      'bayoneta_aceite_motor': bayonetaAceiteOk,
      'tapones': taponesOk,
      'bocina_claxon': bocinaClaxxonOk,
      'radiador': radiadorOk,
      // Herramientas
      'gato': gatoOk,
      'llave_ruedas': llaveLlantasOk,
      'cables_pasa_corriente': cablesPasaCorrienteOk,
      'caja_bolsa_herramientas': cajaHerramientasOk,
      'dado_birlo_seguridad': dadoBirloSeguidadOk,
      // Calcomanías
      'calcomanias_permisos': calcomaniastPermisosOk,
      'calcomania_velocidad_maxima': calcomaniaVelocidadMaximaOk,
      // Observaciones
      'mantenimiento_preventivo': mantenimientoPreventivo,
      'mantenimiento_correctivo': mantenimientoCorrectivo,
      'condicion_carroceria_log': condicionCarroceriaLog,
      'condicion_carroceria_imagen': condicionCarroceriaImagen,
      'responsable_recibo_uso': responsableReciboUso,
      'responsable_entrega': responsableEntrega,
    };
  }
}
