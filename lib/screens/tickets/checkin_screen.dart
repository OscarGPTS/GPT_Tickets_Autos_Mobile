import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';
import '../../models/ticket_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'widgets/form_section_widget.dart';
import 'widgets/form_input_widget.dart';
import 'widgets/checklist_checkbox_widget.dart';
import 'widgets/vehicle_damage_canvas_widget.dart';

class CheckinScreen extends StatefulWidget {
  final TicketModel ticket;
  
  const CheckinScreen({super.key, required this.ticket});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 12;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  bool _isSubmitting = false;
  bool _isLoading = true;

  late ChecklistModel _checklist;
  ChecklistResponseModel? _existingCheckout; // Checkout para precargar datos
  ChecklistResponseModel? _existingCheckin; // Checkin existente
  bool _hasExistingCheckin = false;
  String _condicionCarroceriaImagen = ''; // Base64 de imagen con daños
  
  // Mapa mutable para los valores de los checkboxes
  final Map<String, bool> _checkboxValues = {};
  
  @override
  void initState() {
    super.initState();
    _loadChecklistData();
  }

  Future<void> _loadChecklistData() async {
    setState(() => _isLoading = true);

    try {
      // Verificar si el ticket ya tiene checkin
      _existingCheckin = widget.ticket.checkinChecklist;
      _hasExistingCheckin = _existingCheckin?.exists ?? false;

      // Obtener checkout para precargar
      _existingCheckout = widget.ticket.checkoutChecklist;

      // Inicializar checklist base con datos del ticket
      _checklist = ChecklistModel(
        ticketId: widget.ticket.id,
        tipoInspeccion: 'entrada', // CHECK-IN es entrada
        folio: int.tryParse(widget.ticket.folio.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        fecha: DateTime.now().toString().split(' ')[0],
        destino: widget.ticket.destination ?? '',
        modelo: widget.ticket.vehicle?.model ?? '',
        placas: widget.ticket.vehicle?.plates ?? '',
        marca: widget.ticket.vehicle?.brand ?? '',
        kilometrajeInicial: 0.0,
        nivelCombustibleInicial: '1/2',
      );

      // Si ya existe checkin, cargar sus valores
      if (_hasExistingCheckin && _existingCheckin != null) {
        _loadExistingCheckinValues();
      } else if (_existingCheckout != null) {
        // Si no existe checkin pero sí checkout, precargar desde checkout
        _preloadFromCheckout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadExistingCheckinValues() {
    if (_existingCheckin == null) return;

    // Cargar valores desde checkin existente (mismo código que checkout)
    final llantas = _existingCheckin!.llantas;
    if (llantas != null) {
      _checkboxValues['llantaDelanteraDerechaOk'] = llantas['delantera_derecha'] ?? false;
      _checkboxValues['llantaDelanteraIzquierdaOk'] = llantas['delantera_izquierda'] ?? false;
      _checkboxValues['llantaDelanteraVidaOk'] = llantas['delantera_vida'] ?? false;
      _checkboxValues['llantaTrseraDerechaOk'] = llantas['trasera_derecha'] ?? false;
      _checkboxValues['llantaTraseraIzquierdaOk'] = llantas['trasera_izquierda'] ?? false;
      _checkboxValues['llantaTraseraVidaOk'] = llantas['trasera_vida'] ?? false;
      _checkboxValues['llantaRefaccionOk'] = llantas['refaccion'] ?? false;
      _checkboxValues['presionAdecuadaOk'] = llantas['presion_adecuada'] ?? false;
    }

    final frontal = _existingCheckin!.frontal;
    if (frontal != null) {
      _checkboxValues['parabrisisOk'] = frontal['parabrisas'] ?? false;
      _checkboxValues['cofreOk'] = frontal['cofre'] ?? false;
      _checkboxValues['parrillaOk'] = frontal['parrilla'] ?? false;
      _checkboxValues['defensasOk'] = frontal['defensas'] ?? false;
      _checkboxValues['moldurasOk'] = frontal['molduras'] ?? false;
      _checkboxValues['placaOk'] = frontal['placa'] ?? false;
      _checkboxValues['salpicaderaOk'] = frontal['salpicadera'] ?? false;
      _checkboxValues['antenaOk'] = frontal['antena'] ?? false;
    }

    // Continuar con las demás secciones...
    final luces = _existingCheckin!.luces;
    if (luces != null) {
      _checkboxValues['intermitentesOk'] = luces['intermitentes'] ?? false;
      _checkboxValues['direccionalDerechaOk'] = luces['direccional_derecha'] ?? false;
      _checkboxValues['direccionalIzquierdaOk'] = luces['direccional_izquierda'] ?? false;
      _checkboxValues['luzStopOk'] = luces['luz_stop'] ?? false;
      _checkboxValues['farosOk'] = luces['faros'] ?? false;
      _checkboxValues['lucesAltasOk'] = luces['luces_altas'] ?? false;
      _checkboxValues['luzInteriorOk'] = luces['luz_interior'] ?? false;
      _checkboxValues['calaveras'] = luces['calaveras_buen_estado'] ?? false;
    }

    final seguridad = _existingCheckin!.seguridad;
    if (seguridad != null) {
      _checkboxValues['mataChispassOk'] = seguridad['mata_chispas'] ?? false;
      _checkboxValues['alarmaOk'] = seguridad['alarma'] ?? false;
      _checkboxValues['extintorOk'] = seguridad['extintor'] ?? false;
      _checkboxValues['botiquinOk'] = seguridad['botiquin'] ?? false;
      _checkboxValues['tarjetaCirculacionOk'] = seguridad['tarjeta_circulacion'] ?? false;
      _checkboxValues['licenciaConducirVigenteOk'] = seguridad['licencia_conducir_vigente'] ?? false;
      _checkboxValues['polizaSeguroOk'] = seguridad['poliza_seguro'] ?? false;
      _checkboxValues['trianguloEmergenciaOk'] = seguridad['triangulo_emergencia'] ?? false;
    }

    final interior = _existingCheckin!.interior;
    if (interior != null) {
      _checkboxValues['tableroIndicadoresOk'] = interior['tablero_indicadores'] ?? false;
      _checkboxValues['switchEncendidoOk'] = interior['switch_encendido'] ?? false;
      _checkboxValues['controlesAcOk'] = interior['controles_ac'] ?? false;
      _checkboxValues['defrosterOk'] = interior['defroster'] ?? false;
      _checkboxValues['radioOk'] = interior['radio'] ?? false;
      _checkboxValues['volanteOk'] = interior['volante'] ?? false;
      _checkboxValues['bolsasAireOk'] = interior['bolsas_aire'] ?? false;
      _checkboxValues['cinturonSeguridadOk'] = interior['cintulon_seguridad'] ?? false;
      _checkboxValues['coderasOk'] = interior['coderas'] ?? false;
      _checkboxValues['espejoInteriorOk'] = interior['espejo_interior'] ?? false;
      _checkboxValues['frenoManoOk'] = interior['freno_mano'] ?? false;
      _checkboxValues['encendedorOk'] = interior['encendedor'] ?? false;
      _checkboxValues['guanteraOk'] = interior['guantera'] ?? false;
      _checkboxValues['manijasInterioresOk'] = interior['manijas_interiores'] ?? false;
      _checkboxValues['segurosOk'] = interior['seguros'] ?? false;
      _checkboxValues['asientosOk'] = interior['asientos'] ?? false;
      _checkboxValues['tapetesOk'] = interior['tapetes_delanteros_traseros'] ?? false;
    }

    final motor = _existingCheckin!.motor;
    if (motor != null) {
      _checkboxValues['nivelAceiteMotorOk'] = motor['nivel_aceite_motor'] ?? false;
      _checkboxValues['nivelAnticongelanteOk'] = motor['nivel_anticongelante'] ?? false;
      _checkboxValues['nivelLiquidoFrenosOk'] = motor['nivel_liquido_frenos'] ?? false;
      _checkboxValues['bateriaOk'] = motor['bateria'] ?? false;
      _checkboxValues['bayonetaAceiteOk'] = motor['bayoneta_aceite_motor'] ?? false;
      _checkboxValues['taponesOk'] = motor['tapones'] ?? false;
      _checkboxValues['bocinaClaxxonOk'] = motor['bocina_claxon'] ?? false;
      _checkboxValues['radiadorOk'] = motor['radiador'] ?? false;
    }

    final herramienta = _existingCheckin!.herramienta;
    if (herramienta != null) {
      _checkboxValues['gatoOk'] = herramienta['gato'] ?? false;
      _checkboxValues['llaveLlantasOk'] = herramienta['llave_ruedas'] ?? false;
      _checkboxValues['cablesPasaCorrienteOk'] = herramienta['cables_pasa_corriente'] ?? false;
      _checkboxValues['cajaHerramientasOk'] = herramienta['caja_bolsa_herramientas'] ?? false;
      _checkboxValues['dadoBirloSeguidadOk'] = herramienta['dado_birlo_seguridad'] ?? false;
    }

    final calcomanias = _existingCheckin!.calcomanias;
    if (calcomanias != null) {
      _checkboxValues['calcomaniastPermisosOk'] = calcomanias['calcomanias_permisos'] ?? false;
      _checkboxValues['calcomaniaVelocidadMaximaOk'] = calcomanias['calcomania_velocidad_maxima'] ?? false;
    }
  }

  void _preloadFromCheckout() {
    if (_existingCheckout == null) return;

    // Precargar todos los valores desde el checkout
    final llantas = _existingCheckout!.llantas;
    if (llantas != null) {
      _checkboxValues['llantaDelanteraDerechaOk'] = llantas['delantera_derecha'] ?? true;
      _checkboxValues['llantaDelanteraIzquierdaOk'] = llantas['delantera_izquierda'] ?? true;
      _checkboxValues['llantaDelanteraVidaOk'] = llantas['delantera_vida'] ?? true;
      _checkboxValues['llantaTrseraDerechaOk'] = llantas['trasera_derecha'] ?? true;
      _checkboxValues['llantaTraseraIzquierdaOk'] = llantas['trasera_izquierda'] ?? true;
      _checkboxValues['llantaTraseraVidaOk'] = llantas['trasera_vida'] ?? true;
      _checkboxValues['llantaRefaccionOk'] = llantas['refaccion'] ?? true;
      _checkboxValues['presionAdecuadaOk'] = llantas['presion_adecuada'] ?? true;
    }

    final frontal = _existingCheckout!.frontal;
    if (frontal != null) {
      _checkboxValues['parabrisisOk'] = frontal['parabrisas'] ?? true;
      _checkboxValues['cofreOk'] = frontal['cofre'] ?? true;
      _checkboxValues['parrillaOk'] = frontal['parrilla'] ?? true;
      _checkboxValues['defensasOk'] = frontal['defensas'] ?? true;
      _checkboxValues['moldurasOk'] = frontal['molduras'] ?? true;
      _checkboxValues['placaOk'] = frontal['placa'] ?? true;
      _checkboxValues['salpicaderaOk'] = frontal['salpicadera'] ?? true;
      _checkboxValues['antenaOk'] = frontal['antena'] ?? true;
    }

    final luces = _existingCheckout!.luces;
    if (luces != null) {
      _checkboxValues['intermitentesOk'] = luces['intermitentes'] ?? true;
      _checkboxValues['direccionalDerechaOk'] = luces['direccional_derecha'] ?? true;
      _checkboxValues['direccionalIzquierdaOk'] = luces['direccional_izquierda'] ?? true;
      _checkboxValues['luzStopOk'] = luces['luz_stop'] ?? true;
      _checkboxValues['farosOk'] = luces['faros'] ?? true;
      _checkboxValues['lucesAltasOk'] = luces['luces_altas'] ?? true;
      _checkboxValues['luzInteriorOk'] = luces['luz_interior'] ?? true;
      _checkboxValues['calaveras'] = luces['calaveras_buen_estado'] ?? true;
    }

    final seguridad = _existingCheckout!.seguridad;
    if (seguridad != null) {
      _checkboxValues['mataChispassOk'] = seguridad['mata_chispas'] ?? true;
      _checkboxValues['alarmaOk'] = seguridad['alarma'] ?? true;
      _checkboxValues['extintorOk'] = seguridad['extintor'] ?? true;
      _checkboxValues['botiquinOk'] = seguridad['botiquin'] ?? true;
      _checkboxValues['tarjetaCirculacionOk'] = seguridad['tarjeta_circulacion'] ?? true;
      _checkboxValues['licenciaConducirVigenteOk'] = seguridad['licencia_conducir_vigente'] ?? true;
      _checkboxValues['polizaSeguroOk'] = seguridad['poliza_seguro'] ?? true;
      _checkboxValues['trianguloEmergenciaOk'] = seguridad['triangulo_emergencia'] ?? true;
    }

    final interior = _existingCheckout!.interior;
    if (interior != null) {
      _checkboxValues['tableroIndicadoresOk'] = interior['tablero_indicadores'] ?? true;
      _checkboxValues['switchEncendidoOk'] = interior['switch_encendido'] ?? true;
      _checkboxValues['controlesAcOk'] = interior['controles_ac'] ?? true;
      _checkboxValues['defrosterOk'] = interior['defroster'] ?? true;
      _checkboxValues['radioOk'] = interior['radio'] ?? true;
      _checkboxValues['volanteOk'] = interior['volante'] ?? true;
      _checkboxValues['bolsasAireOk'] = interior['bolsas_aire'] ?? true;
      _checkboxValues['cinturonSeguridadOk'] = interior['cintulon_seguridad'] ?? true;
      _checkboxValues['coderasOk'] = interior['coderas'] ?? true;
      _checkboxValues['espejoInteriorOk'] = interior['espejo_interior'] ?? true;
      _checkboxValues['frenoManoOk'] = interior['freno_mano'] ?? true;
      _checkboxValues['encendedorOk'] = interior['encendedor'] ?? true;
      _checkboxValues['guanteraOk'] = interior['guantera'] ?? true;
      _checkboxValues['manijasInterioresOk'] = interior['manijas_interiores'] ?? true;
      _checkboxValues['segurosOk'] = interior['seguros'] ?? true;
      _checkboxValues['asientosOk'] = interior['asientos'] ?? true;
      _checkboxValues['tapetesOk'] = interior['tapetes_delanteros_traseros'] ?? true;
    }

    final motor = _existingCheckout!.motor;
    if (motor != null) {
      _checkboxValues['nivelAceiteMotorOk'] = motor['nivel_aceite_motor'] ?? true;
      _checkboxValues['nivelAnticongelanteOk'] = motor['nivel_anticongelante'] ?? true;
      _checkboxValues['nivelLiquidoFrenosOk'] = motor['nivel_liquido_frenos'] ?? true;
      _checkboxValues['bateriaOk'] = motor['bateria'] ?? true;
      _checkboxValues['bayonetaAceiteOk'] = motor['bayoneta_aceite_motor'] ?? true;
      _checkboxValues['taponesOk'] = motor['tapones'] ?? true;
      _checkboxValues['bocinaClaxxonOk'] = motor['bocina_claxon'] ?? true;
      _checkboxValues['radiadorOk'] = motor['radiador'] ?? true;
    }

    final herramienta = _existingCheckout!.herramienta;
    if (herramienta != null) {
      _checkboxValues['gatoOk'] = herramienta['gato'] ?? true;
      _checkboxValues['llaveLlantasOk'] = herramienta['llave_ruedas'] ?? true;
      _checkboxValues['cablesPasaCorrienteOk'] = herramienta['cables_pasa_corriente'] ?? true;
      _checkboxValues['cajaHerramientasOk'] = herramienta['caja_bolsa_herramientas'] ?? true;
      _checkboxValues['dadoBirloSeguidadOk'] = herramienta['dado_birlo_seguridad'] ?? true;
    }

    final calcomanias = _existingCheckout!.calcomanias;
    if (calcomanias != null) {
      _checkboxValues['calcomaniastPermisosOk'] = calcomanias['calcomanias_permisos'] ?? true;
      _checkboxValues['calcomaniaVelocidadMaximaOk'] = calcomanias['calcomania_velocidad_maxima'] ?? true;
    }

    // Precargar imagen del checkout si existe
    final observaciones = _existingCheckout!.observaciones;
    if (observaciones != null && observaciones['imagen_danos'] != null) {
      _condicionCarroceriaImagen = observaciones['imagen_danos'] as String;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _checkboxValues.isEmpty && !_hasExistingCheckin && _existingCheckout == null) {
      // Si no hay checkout ni checkin, inicializar con valores por defecto
      _checkboxValues.addAll({
        'llantaDelanteraDerechaOk': true, 'llantaDelanteraIzquierdaOk': true, 'llantaDelanteraVidaOk': true,
        'llantaTrseraDerechaOk': true, 'llantaTraseraIzquierdaOk': true, 'llantaTraseraVidaOk': true,
        'llantaRefaccionOk': true, 'presionAdecuadaOk': true, 'parabrisisOk': true, 'cofreOk': true,
        'parrillaOk': true, 'defensasOk': true, 'moldurasOk': true, 'placaOk': true, 'salpicaderaOk': true,
        'antenaOk': true, 'intermitentesOk': true, 'direccionalDerechaOk': true, 'direccionalIzquierdaOk': true,
        'luzStopOk': true, 'farosOk': true, 'lucesAltasOk': true, 'luzInteriorOk': true, 'calaveras': true,
        'mataChispassOk': true, 'alarmaOk': true, 'extintorOk': true, 'botiquinOk': true,
        'tarjetaCirculacionOk': true, 'licenciaConducirVigenteOk': true, 'polizaSeguroOk': true, 
        'trianguloEmergenciaOk': true, 'tableroIndicadoresOk': true, 'switchEncendidoOk': true,
        'controlesAcOk': true, 'defrosterOk': true, 'radioOk': true, 'volanteOk': true, 'bolsasAireOk': true,
        'cinturonSeguridadOk': true, 'coderasOk': true, 'espejoInteriorOk': true, 'frenoManoOk': true, 
        'encendedorOk': true, 'guanteraOk': true, 'manijasInterioresOk': true, 'segurosOk': true, 
        'asientosOk': true, 'tapetesOk': true, 'nivelAceiteMotorOk': true, 'nivelAnticongelanteOk': true,
        'nivelLiquidoFrenosOk': true, 'bateriaOk': true, 'bayonetaAceiteOk': true, 'taponesOk': true,
        'bocinaClaxxonOk': true, 'radiadorOk': true, 'gatoOk': true, 'llaveLlantasOk': true,
        'cablesPasaCorrienteOk': true, 'cajaHerramientasOk': true, 'dadoBirloSeguidadOk': true,
        'calcomaniastPermisosOk': true, 'calcomaniaVelocidadMaximaOk': true,
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Prevenir múltiples envíos
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final checklistCompleto = ChecklistModel(
        ticketId: _checklist.ticketId,
        tipoInspeccion: 'entrada', // CHECK-IN
        folio: _checklist.folio,
        fecha: _checklist.fecha,
        destino: _checklist.destino,
        modelo: _checklist.modelo,
        placas: _checklist.placas,
        marca: _checklist.marca,
        horaSalida: _checklist.horaSalida,
        horaEntrada: _checklist.horaEntrada,
        kilometrajeInicial: _checklist.kilometrajeInicial,
        kilometrajeFinal: _checklist.kilometrajeFinal,
        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
        nivelCombustibleFinal: _checklist.nivelCombustibleFinal,
        llantaDelanteraDerechaOk: _checkboxValues['llantaDelanteraDerechaOk'] ?? true,
        llantaDelanteraIzquierdaOk: _checkboxValues['llantaDelanteraIzquierdaOk'] ?? true,
        llantaDelanteraVidaOk: _checkboxValues['llantaDelanteraVidaOk'] ?? true,
        llantaTrseraDerechaOk: _checkboxValues['llantaTrseraDerechaOk'] ?? true,
        llantaTraseraIzquierdaOk: _checkboxValues['llantaTraseraIzquierdaOk'] ?? true,
        llantaTraseraVidaOk: _checkboxValues['llantaTraseraVidaOk'] ?? true,
        llantaRefaccionOk: _checkboxValues['llantaRefaccionOk'] ?? true,
        presionAdecuadaOk: _checkboxValues['presionAdecuadaOk'] ?? true,
        parabrisisOk: _checkboxValues['parabrisisOk'] ?? true,
        cofreOk: _checkboxValues['cofreOk'] ?? true,
        parrillaOk: _checkboxValues['parrillaOk'] ?? true,
        defensasOk: _checkboxValues['defensasOk'] ?? true,
        moldurasOk: _checkboxValues['moldurasOk'] ?? true,
        placaOk: _checkboxValues['placaOk'] ?? true,
        salpicaderaOk: _checkboxValues['salpicaderaOk'] ?? true,
        antenaOk: _checkboxValues['antenaOk'] ?? true,
        intermitentesOk: _checkboxValues['intermitentesOk'] ?? true,
        direccionalDerechaOk: _checkboxValues['direccionalDerechaOk'] ?? true,
        direccionalIzquierdaOk: _checkboxValues['direccionalIzquierdaOk'] ?? true,
        luzStopOk: _checkboxValues['luzStopOk'] ?? true,
        farosOk: _checkboxValues['farosOk'] ?? true,
        lucesAltasOk: _checkboxValues['lucesAltasOk'] ?? true,
        luzInteriorOk: _checkboxValues['luzInteriorOk'] ?? true,
        calaveras: _checkboxValues['calaveras'] ?? true,
        mataChispassOk: _checkboxValues['mataChispassOk'] ?? true,
        alarmaOk: _checkboxValues['alarmaOk'] ?? true,
        extintorOk: _checkboxValues['extintorOk'] ?? true,
        botiquinOk: _checkboxValues['botiquinOk'] ?? true,
        tarjetaCirculacionOk: _checkboxValues['tarjetaCirculacionOk'] ?? true,
        licenciaConducirVigenteOk: _checkboxValues['licenciaConducirVigenteOk'] ?? true,
        polizaSeguroOk: _checkboxValues['polizaSeguroOk'] ?? true,
        trianguloEmergenciaOk: _checkboxValues['trianguloEmergenciaOk'] ?? true,
        tableroIndicadoresOk: _checkboxValues['tableroIndicadoresOk'] ?? true,
        switchEncendidoOk: _checkboxValues['switchEncendidoOk'] ?? true,
        controlesAcOk: _checkboxValues['controlesAcOk'] ?? true,
        defrosterOk: _checkboxValues['defrosterOk'] ?? true,
        radioOk: _checkboxValues['radioOk'] ?? true,
        volanteOk: _checkboxValues['volanteOk'] ?? true,
        bolsasAireOk: _checkboxValues['bolsasAireOk'] ?? true,
        cinturonSeguridadOk: _checkboxValues['cinturonSeguridadOk'] ?? true,
        coderasOk: _checkboxValues['coderasOk'] ?? true,
        espejoInteriorOk: _checkboxValues['espejoInteriorOk'] ?? true,
        frenoManoOk: _checkboxValues['frenoManoOk'] ?? true,
        encendedorOk: _checkboxValues['encendedorOk'] ?? true,
        guanteraOk: _checkboxValues['guanteraOk'] ?? true,
        manijasInterioresOk: _checkboxValues['manijasInterioresOk'] ?? true,
        segurosOk: _checkboxValues['segurosOk'] ?? true,
        asientosOk: _checkboxValues['asientosOk'] ?? true,
        tapetesOk: _checkboxValues['tapetesOk'] ?? true,
        nivelAceiteMotorOk: _checkboxValues['nivelAceiteMotorOk'] ?? true,
        nivelAnticongelanteOk: _checkboxValues['nivelAnticongelanteOk'] ?? true,
        nivelLiquidoFrenosOk: _checkboxValues['nivelLiquidoFrenosOk'] ?? true,
        bateriaOk: _checkboxValues['bateriaOk'] ?? true,
        bayonetaAceiteOk: _checkboxValues['bayonetaAceiteOk'] ?? true,
        taponesOk: _checkboxValues['taponesOk'] ?? true,
        bocinaClaxxonOk: _checkboxValues['bocinaClaxxonOk'] ?? true,
        radiadorOk: _checkboxValues['radiadorOk'] ?? true,
        gatoOk: _checkboxValues['gatoOk'] ?? true,
        llaveLlantasOk: _checkboxValues['llaveLlantasOk'] ?? true,
        cablesPasaCorrienteOk: _checkboxValues['cablesPasaCorrienteOk'] ?? true,
        cajaHerramientasOk: _checkboxValues['cajaHerramientasOk'] ?? true,
        dadoBirloSeguidadOk: _checkboxValues['dadoBirloSeguidadOk'] ?? true,
        calcomaniastPermisosOk: _checkboxValues['calcomaniastPermisosOk'] ?? true,
        calcomaniaVelocidadMaximaOk: _checkboxValues['calcomaniaVelocidadMaximaOk'] ?? true,
        condicionCarroceriaImagen: _condicionCarroceriaImagen,
      );

      // Enviar a la API usando submitCheckin
      final response = await _apiService.submitCheckin(
        ticketId: widget.ticket.id,
        checklistData: checklistCompleto.toJson(),
      );

      if (!mounted) return;

      if (response.success) {
        // Actualizar ticket en storage local
        if (response.data?.ticket != null) {
          await _storageService.updateTicket(response.data!.ticket);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in enviado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Regresar con resultado
      } else {
        throw Exception(response.message ?? 'Error al enviar check-in');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hasExistingCheckin ? 'Ver Check-in' : 'Realizar Check-in'),
        backgroundColor: scheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasExistingCheckin
              ? _buildExistingCheckinView(scheme)
              : _buildCheckinForm(scheme),
    );
  }

  Widget _buildExistingCheckinView(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: scheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Check-in ya realizado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Este ticket ya tiene un check-in registrado',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinForm(ColorScheme scheme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Banner informativo
            if (_existingCheckout != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los datos se han precargado desde el checkout. Verifica y ajusta según sea necesario.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Paso 1: Información del Ticket
            if (_currentStep == 1)
              FormSectionWidget(
                step: 1,
                totalSteps: _totalSteps,
                title: 'Información del Ticket',
                description: 'Datos generales del vehículo',
                children: [
                  FormInputWidget(
                    label: 'Folio',
                    value: _checklist.folio.toString(),
                    onChanged: (_) {},
                  ),
                  FormInputWidget(
                    label: 'Destino',
                    value: _checklist.destino,
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: v,
                        modelo: _checklist.modelo,
                        placas: _checklist.placas,
                        marca: _checklist.marca,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                      );
                    }),
                  ),
                  FormInputWidget(
                    label: 'Modelo',
                    value: _checklist.modelo,
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: _checklist.destino,
                        modelo: v,
                        placas: _checklist.placas,
                        marca: _checklist.marca,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                      );
                    }),
                  ),
                  FormInputWidget(
                    label: 'Placas',
                    value: _checklist.placas,
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: _checklist.destino,
                        modelo: _checklist.modelo,
                        placas: v,
                        marca: _checklist.marca,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                      );
                    }),
                  ),
                  FormInputWidget(
                    label: 'Marca',
                    value: _checklist.marca,
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: _checklist.destino,
                        modelo: _checklist.modelo,
                        placas: _checklist.placas,
                        marca: v,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                      );
                    }),
                  ),
                ],
              ),

            // Paso 2: Tiempos y Kilometraje
            if (_currentStep == 2)
              FormSectionWidget(
                step: 2,
                totalSteps: _totalSteps,
                title: 'Tiempos y Kilometraje',
                description: 'Registra entrada y mediciones',
                children: [
                  FormInputWidget(
                    label: 'Hora Entrada',
                    hint: 'HH:MM',
                    value: _checklist.horaEntrada,
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: _checklist.destino,
                        modelo: _checklist.modelo,
                        placas: _checklist.placas,
                        marca: _checklist.marca,
                        horaSalida: _checklist.horaSalida,
                        horaEntrada: v,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        kilometrajeFinal: _checklist.kilometrajeFinal,
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                        nivelCombustibleFinal: _checklist.nivelCombustibleFinal,
                      );
                    }),
                  ),
                  FormInputWidget(
                    label: 'Kilometraje Final',
                    hint: 'Kilometraje al regreso',
                    value: _checklist.kilometrajeFinal?.toString() ?? '',
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: _checklist.destino,
                        modelo: _checklist.modelo,
                        placas: _checklist.placas,
                        marca: _checklist.marca,
                        horaSalida: _checklist.horaSalida,
                        horaEntrada: _checklist.horaEntrada,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        kilometrajeFinal: double.tryParse(v),
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                        nivelCombustibleFinal: _checklist.nivelCombustibleFinal,
                      );
                    }),
                  ),
                  FormInputWidget(
                    label: 'Combustible Final',
                    hint: '1/2, 3/4, etc',
                    value: _checklist.nivelCombustibleFinal,
                    onChanged: (v) => setState(() {
                      _checklist = ChecklistModel(
                        ticketId: _checklist.ticketId,
                        tipoInspeccion: _checklist.tipoInspeccion,
                        folio: _checklist.folio,
                        fecha: _checklist.fecha,
                        destino: _checklist.destino,
                        modelo: _checklist.modelo,
                        placas: _checklist.placas,
                        marca: _checklist.marca,
                        horaSalida: _checklist.horaSalida,
                        horaEntrada: _checklist.horaEntrada,
                        kilometrajeInicial: _checklist.kilometrajeInicial,
                        kilometrajeFinal: _checklist.kilometrajeFinal,
                        nivelCombustibleInicial: _checklist.nivelCombustibleInicial,
                        nivelCombustibleFinal: v,
                      );
                    }),
                  ),
                ],
              ),

            // Paso 3: Llantas
            if (_currentStep == 3)
              FormSectionWidget(
                step: 3,
                totalSteps: _totalSteps,
                title: 'Llantas',
                description: 'Verifica el estado de todas las llantas',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(
                        label: 'Delantera Derecha',
                        value: _checkboxValues['llantaDelanteraDerechaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaDelanteraDerechaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Delantera Izquierda',
                        value: _checkboxValues['llantaDelanteraIzquierdaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaDelanteraIzquierdaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Delantera Vida',
                        value: _checkboxValues['llantaDelanteraVidaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaDelanteraVidaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Trasera Derecha',
                        value: _checkboxValues['llantaTrseraDerechaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaTrseraDerechaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Trasera Izquierda',
                        value: _checkboxValues['llantaTraseraIzquierdaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaTraseraIzquierdaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Trasera Vida',
                        value: _checkboxValues['llantaTraseraVidaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaTraseraVidaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Refacción',
                        value: _checkboxValues['llantaRefaccionOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['llantaRefaccionOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Presión Adecuada',
                        value: _checkboxValues['presionAdecuadaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['presionAdecuadaOk'] = v),
                      ),
                    ],
                  ),
                ],
              ),

            // Paso 4: Frontal
            if (_currentStep == 4)
              FormSectionWidget(
                step: 4,
                totalSteps: _totalSteps,
                title: 'Parte Frontal',
                description: 'Verifica parabrisas, cofre, defensas, etc.',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(
                        label: 'Parabrisas',
                        value: _checkboxValues['parabrisisOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['parabrisisOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Cofre',
                        value: _checkboxValues['cofreOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['cofreOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Parrilla',
                        value: _checkboxValues['parrillaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['parrillaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Defensas',
                        value: _checkboxValues['defensasOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['defensasOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Molduras',
                        value: _checkboxValues['moldurasOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['moldurasOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Placa',
                        value: _checkboxValues['placaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['placaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Salpicadera',
                        value: _checkboxValues['salpicaderaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['salpicaderaOk'] = v),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Antena',
                        value: _checkboxValues['antenaOk'] ?? false,
                        onChanged: (v) => setState(() => _checkboxValues['antenaOk'] = v),
                      ),
                    ],
                  ),
                ],
              ),

            // Paso 5: Luces
            if (_currentStep == 5)
              FormSectionWidget(
                step: 5,
                totalSteps: _totalSteps,
                title: 'Luces',
                description: 'Verifica todas las luces del vehículo',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(label: 'Intermitentes', value: _checkboxValues['intermitentesOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['intermitentesOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Direc. Der', value: _checkboxValues['direccionalDerechaOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['direccionalDerechaOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Direc. Izq', value: _checkboxValues['direccionalIzquierdaOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['direccionalIzquierdaOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Luz Stop', value: _checkboxValues['luzStopOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['luzStopOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Faros', value: _checkboxValues['farosOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['farosOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Luces Altas', value: _checkboxValues['lucesAltasOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['lucesAltasOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Luz Interior', value: _checkboxValues['luzInteriorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['luzInteriorOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Calaveras', value: _checkboxValues['calaveras'] ?? false, onChanged: (v) => setState(() => _checkboxValues['calaveras'] = v)),
                    ],
                  ),
                ],
              ),

            // Paso 6: Seguridad
            if (_currentStep == 6)
              FormSectionWidget(
                step: 6,
                totalSteps: _totalSteps,
                title: 'Seguridad',
                description: 'Verifica equipos de seguridad',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(label: 'Mata Chispas', value: _checkboxValues['mataChispassOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['mataChispassOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Alarma', value: _checkboxValues['alarmaOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['alarmaOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Extintor', value: _checkboxValues['extintorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['extintorOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Botiquín', value: _checkboxValues['botiquinOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['botiquinOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Tarjeta Circ', value: _checkboxValues['tarjetaCirculacionOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['tarjetaCirculacionOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Licencia', value: _checkboxValues['licenciaConducirVigenteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['licenciaConducirVigenteOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Póliza Seg', value: _checkboxValues['polizaSeguroOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['polizaSeguroOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Triángulo', value: _checkboxValues['trianguloEmergenciaOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['trianguloEmergenciaOk'] = v)),
                    ],
                  ),
                ],
              ),

            // Paso 7: Interior
            if (_currentStep == 7)
              FormSectionWidget(
                step: 7,
                totalSteps: _totalSteps,
                title: 'Interior',
                description: 'Verifica componentes interiores',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(label: 'Tablero', value: _checkboxValues['tableroIndicadoresOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['tableroIndicadoresOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Switch', value: _checkboxValues['switchEncendidoOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['switchEncendidoOk'] = v)),
                      ChecklistCheckboxWidget(label: 'A/C', value: _checkboxValues['controlesAcOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['controlesAcOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Defroster', value: _checkboxValues['defrosterOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['defrosterOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Radio', value: _checkboxValues['radioOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['radioOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Volante', value: _checkboxValues['volanteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['volanteOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Bolsas Aire', value: _checkboxValues['bolsasAireOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['bolsasAireOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Cinturón', value: _checkboxValues['cinturonSeguridadOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['cinturonSeguridadOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Coderas', value: _checkboxValues['coderasOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['coderasOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Espejo', value: _checkboxValues['espejoInteriorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['espejoInteriorOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Freno Mano', value: _checkboxValues['frenoManoOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['frenoManoOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Encendedor', value: _checkboxValues['encendedorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['encendedorOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Guantera', value: _checkboxValues['guanteraOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['guanteraOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Manijas', value: _checkboxValues['manijasInterioresOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['manijasInterioresOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Seguros', value: _checkboxValues['segurosOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['segurosOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Asientos', value: _checkboxValues['asientosOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['asientosOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Tapetes', value: _checkboxValues['tapetesOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['tapetesOk'] = v)),
                    ],
                  ),
                ],
              ),

            // Paso 8: Motor
            if (_currentStep == 8)
              FormSectionWidget(
                step: 8,
                totalSteps: _totalSteps,
                title: 'Motor',
                description: 'Verifica componentes del motor',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(label: 'Aceite Motor', value: _checkboxValues['nivelAceiteMotorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['nivelAceiteMotorOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Anticongelante', value: _checkboxValues['nivelAnticongelanteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['nivelAnticongelanteOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Líquido Frenos', value: _checkboxValues['nivelLiquidoFrenosOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['nivelLiquidoFrenosOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Batería', value: _checkboxValues['bateriaOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['bateriaOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Bayoneta', value: _checkboxValues['bayonetaAceiteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['bayonetaAceiteOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Tapones', value: _checkboxValues['taponesOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['taponesOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Claxon', value: _checkboxValues['bocinaClaxxonOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['bocinaClaxxonOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Radiador', value: _checkboxValues['radiadorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['radiadorOk'] = v)),
                    ],
                  ),
                ],
              ),

            // Paso 9: Herramientas
            if (_currentStep == 9)
              FormSectionWidget(
                step: 9,
                totalSteps: _totalSteps,
                title: 'Herramientas',
                description: 'Verifica equipos y herramientas',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(label: 'Gato', value: _checkboxValues['gatoOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['gatoOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Llave Llantas', value: _checkboxValues['llaveLlantasOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['llaveLlantasOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Cables Corriente', value: _checkboxValues['cablesPasaCorrienteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['cablesPasaCorrienteOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Caja Herr', value: _checkboxValues['cajaHerramientasOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['cajaHerramientasOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Birlo Seg', value: _checkboxValues['dadoBirloSeguidadOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['dadoBirloSeguidadOk'] = v)),
                    ],
                  ),
                ],
              ),

            // Paso 10: Calcomanías
            if (_currentStep == 10)
              FormSectionWidget(
                step: 10,
                totalSteps: _totalSteps,
                title: 'Calcomanías',
                description: 'Verifica pegatinas y calcomanías',
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ChecklistCheckboxWidget(label: 'Permisos', value: _checkboxValues['calcomaniastPermisosOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['calcomaniastPermisosOk'] = v)),
                      ChecklistCheckboxWidget(label: 'Veloc Máx', value: _checkboxValues['calcomaniaVelocidadMaximaOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['calcomaniaVelocidadMaximaOk'] = v)),
                    ],
                  ),
                ],
              ),

            // Paso 11: Canvas de daños
            if (_currentStep == 11)
              FormSectionWidget(
                step: 11,
                totalSteps: _totalSteps,
                title: 'Condición de Carrocería',
                description: 'Dibuja los daños detectados en el vehículo',
                children: [
                  VehicleDamageCanvasWidget(
                    onImageSaved: (base64Image) {
                      setState(() {
                        _condicionCarroceriaImagen = base64Image;
                      });
                    },
                  ),
                ],
              ),

            // Paso 12: Observaciones
            if (_currentStep == 12)
              FormSectionWidget(
                step: 12,
                totalSteps: _totalSteps,
                title: 'Observaciones',
                description: 'Registra observaciones generales',
                children: [
                  FormInputWidget(
                    label: 'Observaciones Generales',
                    hint: 'Notas adicionales sobre el vehículo...',
                    value: '',
                    onChanged: (_) {},
                    maxLines: 5,
                  ),
                ],
              ),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Atrás'),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : (_currentStep == _totalSteps ? _submit : _nextStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_currentStep == _totalSteps ? 'Enviar Check-in' : 'Siguiente'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
