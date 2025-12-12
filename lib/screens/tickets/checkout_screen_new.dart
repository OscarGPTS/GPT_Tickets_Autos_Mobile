import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';
import '../../models/ticket_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'widgets/form_section_widget.dart';
import 'widgets/form_input_widget.dart';
import 'widgets/checklist_checkbox_widget.dart';
import 'widgets/vehicle_damage_canvas_widget.dart';

class CheckoutScreenNew extends StatefulWidget {
  final TicketModel ticket;
  
  const CheckoutScreenNew({super.key, required this.ticket});

  @override
  State<CheckoutScreenNew> createState() => _CheckoutScreenNewState();
}

class _CheckoutScreenNewState extends State<CheckoutScreenNew> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 12;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  bool _isSubmitting = false;
  bool _isLoading = true;

  late ChecklistModel _checklist;
  ChecklistResponseModel? _existingChecklist; // Checklist existente desde el backend
  bool _hasExistingChecklist = false;
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
      // Verificar si el ticket ya tiene un checkout checklist
      _existingChecklist = widget.ticket.checkoutChecklist;
      _hasExistingChecklist = _existingChecklist?.exists ?? false;

      // Inicializar checklist con datos del ticket
      _checklist = ChecklistModel(
        ticketId: widget.ticket.id,
        tipoInspeccion: 'salida',
        folio: int.tryParse(widget.ticket.folio.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        fecha: DateTime.now().toString().split(' ')[0],
        destino: widget.ticket.destination ?? '',
        modelo: widget.ticket.vehicle?.model ?? '',
        placas: widget.ticket.vehicle?.plates ?? '',
        marca: widget.ticket.vehicle?.brand ?? '',
        kilometrajeInicial: 0,
        nivelCombustibleInicial: '1/2',
      );

      // Si existe checklist, cargar sus valores
      if (_hasExistingChecklist && _existingChecklist != null) {
        _loadExistingChecklistValues();
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

  void _loadExistingChecklistValues() {
    if (_existingChecklist == null) return;

    // Cargar valores de llantas
    final llantas = _existingChecklist!.llantas;
    if (llantas != null) {
      _checkboxValues['llantaDelanteraDerechaOk'] = llantas['llanta_delantera_derecha'] ?? false;
      _checkboxValues['llantaDelanteraIzquierdaOk'] = llantas['llanta_delantera_izquierda'] ?? false;
      _checkboxValues['llantaDelanteraVidaOk'] = llantas['llanta_delantera_vida'] ?? false;
      _checkboxValues['llantaTrseraDerechaOk'] = llantas['llanta_trasera_derecha'] ?? false;
      _checkboxValues['llantaTraseraIzquierdaOk'] = llantas['llanta_trasera_izquierda'] ?? false;
      _checkboxValues['llantaTraseraVidaOk'] = llantas['llanta_trasera_vida'] ?? false;
      _checkboxValues['llantaRefaccionOk'] = llantas['llanta_refaccion'] ?? false;
      _checkboxValues['presionAdecuadaOk'] = llantas['presion_adecuada'] ?? false;
    }

    // Cargar valores de frontal
    final frontal = _existingChecklist!.frontal;
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

    // Cargar demás secciones...
    final luces = _existingChecklist!.luces;
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

    // Cargar imagen de daños si existe
    final observaciones = _existingChecklist!.observaciones;
    if (observaciones != null) {
      _condicionCarroceriaImagen = observaciones['condicion_carroceria_imagen']?.toString() ?? '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _checkboxValues.isEmpty && !_hasExistingChecklist) {
      // Inicializar todos los valores del mapa con true por defecto (mejor UX)
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
      'controlesAcOk': true, 'defrosterOk': true, 'radioOk': true, 'volanteOk': true,
      'bolsasAireOk': true, 'cinturonSeguridadOk': true, 'coderasOk': true, 'espejoInteriorOk': true,
      'frenoManoOk': true, 'encendedorOk': true, 'guanteraOk': true, 'manijasInterioresOk': true,
      'segurosOk': true, 'asientosOk': true, 'tapetesOk': true, 'nivelAceiteMotorOk': true,
      'nivelAnticongelanteOk': true, 'nivelLiquidoFrenosOk': true, 'bateriaOk': true, 'bayonetaAceiteOk': true,
      'taponesOk': true, 'bocinaClaxxonOk': true, 'radiadorOk': true, 'gatoOk': true, 'llaveLlantasOk': true,
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
      // Crear el modelo actualizado con la imagen de daños
      final checklistCompleto = ChecklistModel(
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

      // Enviar a la API
      final response = await _apiService.submitCheckout(
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
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retornar true para indicar éxito
      } else {
        // Mostrar errores de validación si existen
        String errorMsg = response.message;
        if (response.errors != null) {
          final errors = response.errors!.values.join('\n');
          errorMsg += '\n$errors';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Ejemplo de método para enviar a API
  // Future<void> _submitChecklistToAPI(Map<String, dynamic> data) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://tu-api.com/checklists'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data),
  //     );
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       // Éxito
  //     } else {
  //       throw Exception('Error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error enviando checklist: $e');
  //     rethrow;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hasExistingChecklist ? 'Ver Checkout' : 'Realizar Checkout'),
        backgroundColor: scheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasExistingChecklist
              ? _buildExistingChecklistView(scheme)
              : _buildCheckoutForm(scheme),
    );
  }

  Widget _buildExistingChecklistView(ColorScheme scheme) {
    if (_existingChecklist == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de información
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checkout ya realizado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Este ticket ya tiene un checkout registrado el ${_existingChecklist!.fecha ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Información general
          _buildReadOnlySection('Información General', [
            _buildReadOnlyItem('Folio', _existingChecklist!.folio),
            _buildReadOnlyItem('Fecha', _existingChecklist!.fecha?.toString() ?? 'N/A'),
            _buildReadOnlyItem('Destino', _existingChecklist!.destino?.toString() ?? 'N/A'),
            _buildReadOnlyItem('Hora de Salida', _existingChecklist!.horaSalida?.toString() ?? 'N/A'),
            _buildReadOnlyItem('Kilometraje Inicial', '${_existingChecklist!.kilometrajeInicial ?? 0} km'),
            _buildReadOnlyItem('Nivel Combustible', _existingChecklist!.nivelCombustibleInicial?.toString() ?? 'N/A'),
          ]),

          // Vehículo
          _buildReadOnlySection('Vehículo', [
            _buildReadOnlyItem('Marca', _existingChecklist!.marca?.toString() ?? 'N/A'),
            _buildReadOnlyItem('Modelo', _existingChecklist!.modelo?.toString() ?? 'N/A'),
            _buildReadOnlyItem('Placas', _existingChecklist!.placas?.toString() ?? 'N/A'),
          ]),

          // Resumen de inspección
          if (_existingChecklist!.llantas != null)
            _buildChecklistSummary('Llantas', _existingChecklist!.llantas!),
          if (_existingChecklist!.frontal != null)
            _buildChecklistSummary('Frontal', _existingChecklist!.frontal!),
          if (_existingChecklist!.luces != null)
            _buildChecklistSummary('Luces', _existingChecklist!.luces!),
          if (_existingChecklist!.seguridad != null)
            _buildChecklistSummary('Seguridad', _existingChecklist!.seguridad!),
          if (_existingChecklist!.interior != null)
            _buildChecklistSummary('Interior', _existingChecklist!.interior!),
          if (_existingChecklist!.motor != null)
            _buildChecklistSummary('Motor', _existingChecklist!.motor!),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlySection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSummary(String title, Map<String, dynamic> items) {
    final okItems = items.entries.where((e) => e.value == true).length;
    final totalItems = items.length;
    final percentage = totalItems > 0 ? (okItems / totalItems * 100).round() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: percentage >= 80 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                percentage >= 80 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$okItems de $totalItems elementos en buen estado',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutForm(ColorScheme scheme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
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
                  description: 'Registra horarios y combustible',
                  children: [
                    FormInputWidget(
                      label: 'Hora Salida',
                      hint: '09:00',
                      value: _checklist.horaSalida,
                      onChanged: (v) {},
                    ),
                    FormInputWidget(
                      label: 'Hora Entrada',
                      hint: '18:00',
                      value: _checklist.horaEntrada,
                      onChanged: (v) {},
                    ),
                    FormInputWidget(
                      label: 'Km Inicial',
                      hint: '0',
                      value: _checklist.kilometrajeInicial.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {},
                    ),
                    FormInputWidget(
                      label: 'Km Final',
                      hint: '0',
                      value: _checklist.kilometrajeFinal?.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {},
                    ),
                    FormInputWidget(
                      label: 'Combustible Inicial',
                      value: _checklist.nivelCombustibleInicial,
                      onChanged: (v) {},
                    ),
                    FormInputWidget(
                      label: 'Combustible Final',
                      value: _checklist.nivelCombustibleFinal,
                      onChanged: (v) {},
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
                          label: 'Delantera Izq',
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
                          label: 'Trasera Izq',
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
                          label: 'Presión OK',
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
                        ChecklistCheckboxWidget(
                          label: 'Intermitentes',
                          value: _checkboxValues['intermitentesOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['intermitentesOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Direccional Der',
                          value: _checkboxValues['direccionalDerechaOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['direccionalDerechaOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Direccional Izq',
                          value: _checkboxValues['direccionalIzquierdaOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['direccionalIzquierdaOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Luz Stop',
                          value: _checkboxValues['luzStopOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['luzStopOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Faros',
                          value: _checkboxValues['farosOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['farosOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Luces Altas',
                          value: _checkboxValues['lucesAltasOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['lucesAltasOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Luz Interior',
                          value: _checkboxValues['luzInteriorOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['luzInteriorOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Calaveras',
                          value: _checkboxValues['calaveras'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['calaveras'] = v),
                        ),
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
                        ChecklistCheckboxWidget(
                          label: 'Mata Chispas',
                          value: _checkboxValues['mataChispassOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['mataChispassOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Alarma',
                          value: _checkboxValues['alarmaOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['alarmaOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Extintor',
                          value: _checkboxValues['extintorOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['extintorOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Botiquín',
                          value: _checkboxValues['botiquinOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['botiquinOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Tarjeta Circ',
                          value: _checkboxValues['tarjetaCirculacionOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['tarjetaCirculacionOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Licencia OK',
                          value: _checkboxValues['licenciaConducirVigenteOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['licenciaConducirVigenteOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Póliza Seg',
                          value: _checkboxValues['polizaSeguroOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['polizaSeguroOk'] = v),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Triángulo',
                          value: _checkboxValues['trianguloEmergenciaOk'] ?? false,
                          onChanged: (v) => setState(() => _checkboxValues['trianguloEmergenciaOk'] = v),
                        ),
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
                        ChecklistCheckboxWidget(label: 'AC', value: _checkboxValues['controlesAcOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['controlesAcOk'] = v)),
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
                        ChecklistCheckboxWidget(label: 'Aceite', value: _checkboxValues['nivelAceiteMotorOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['nivelAceiteMotorOk'] = v)),
                        ChecklistCheckboxWidget(label: 'Anticongelante', value: _checkboxValues['nivelAnticongelanteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['nivelAnticongelanteOk'] = v)),
                        ChecklistCheckboxWidget(label: 'Frenos', value: _checkboxValues['nivelLiquidoFrenosOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['nivelLiquidoFrenosOk'] = v)),
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
                        ChecklistCheckboxWidget(label: 'Llave Ruedas', value: _checkboxValues['llaveLlantasOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['llaveLlantasOk'] = v)),
                        ChecklistCheckboxWidget(label: 'Cables', value: _checkboxValues['cablesPasaCorrienteOk'] ?? false, onChanged: (v) => setState(() => _checkboxValues['cablesPasaCorrienteOk'] = v)),
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

              // Paso 11: Condición de Carrocería
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
                  description: 'Registra observaciones y daños',
                  children: [
                    FormInputWidget(
                      label: 'Mantenimiento Preventivo',
                      hint: 'Describe tareas preventivas...',
                      value: _checklist.mantenimientoPreventivo,
                      onChanged: (_) {},
                      maxLines: 3,
                    ),
                    FormInputWidget(
                      label: 'Mantenimiento Correctivo',
                      hint: 'Describe reparaciones realizadas...',
                      value: _checklist.mantenimientoCorrectivo,
                      onChanged: (_) {},
                      maxLines: 3,
                    ),
                    FormInputWidget(
                      label: 'Responsable Recibo',
                      hint: 'Nombre de quién recibe',
                      value: _checklist.responsableReciboUso,
                      onChanged: (_) {},
                    ),
                    FormInputWidget(
                      label: 'Responsable Entrega',
                      hint: 'Nombre de quién entrega',
                      value: _checklist.responsableEntrega,
                      onChanged: (_) {},
                    ),
                  ],
                ),

              // Botones
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
                            : Text(
                                _currentStep == _totalSteps ? 'Enviar' : 'Siguiente',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
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
