import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';
import '../../models/ticket_model.dart';
import '../../services/checkin_service.dart';
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

  final CheckinService _checkinService = CheckinService();
  final StorageService _storageService = StorageService();
  bool _isSubmitting = false;
  bool _isLoading = true;

  bool _hasExistingCheckin = false;
  
  // Copia local del ticket para trabajar
  late TicketModel _ticket;
  
  // Map con todos los datos del checklist (se envía directo al API)
  late Map<String, dynamic> _checklistData;
  
  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    
    // Inicializar datos del checklist
    _checklistData = {
      'ticket_id': _ticket.id,
      'tipo_inspeccion': 'entrada',
      'folio': _ticket.folio,
      'destino': _ticket.destination ?? '',
      'modelo': _ticket.vehicle?.model ?? '',
      'placas': _ticket.vehicle?.plates ?? '',
      'marca': _ticket.vehicle?.brand ?? '',
      // Checkboxes por defecto en true
      'llanta_delantera_derecha': true,
      'llanta_delantera_izquierda': true,
      'llanta_delantera_vida': true,
      'llanta_trasera_derecha': true,
      'llanta_trasera_izquierda': true,
      'llanta_trasera_vida': true,
      'llanta_refaccion': true,
      'presion_adecuada': true,
      'parabrisas': true,
      'cofre': true,
      'parrilla': true,
      'defensas': true,
      'molduras': true,
      'placa': true,
      'salpicadera': true,
      'antena': true,
      'intermitentes': true,
      'direccional_derecha': true,
      'direccional_izquierda': true,
      'luz_stop': true,
      'faros': true,
      'luces_altas': true,
      'luz_interior': true,
      'calaveras_buen_estado': true,
      'mata_chispas': true,
      'alarma': true,
      'extintor': true,
      'botiquin': true,
      'tarjeta_circulacion': true,
      'licencia_conducir_vigente': true,
      'poliza_seguro': true,
      'triangulo_emergencia': true,
      'tablero_indicadores': true,
      'switch_encendido': true,
      'controles_ac': true,
      'defroster': true,
      'radio': true,
      'volante': true,
      'bolsas_aire': true,
      'cintulon_seguridad': true,
      'coderas': true,
      'espejo_interior': true,
      'freno_mano': true,
      'encendedor': true,
      'guantera': true,
      'manijas_interiores': true,
      'seguros': true,
      'asientos': true,
      'tapetes_delanteros_traseros': true,
      'nivel_aceite_motor': true,
      'nivel_anticongelante': true,
      'nivel_liquido_frenos': true,
      'bateria': true,
      'bayoneta_aceite_motor': true,
      'tapones': true,
      'bocina_claxon': true,
      'radiador': true,
      'gato': true,
      'llave_ruedas': true,
      'cables_pasa_corriente': true,
      'caja_bolsa_herramientas': true,
      'dado_birlo_seguridad': true,
      'calcomanias_permisos': true,
      'calcomania_velocidad_maxima': true,
    };
    
    _loadChecklistData();
  }

  Future<void> _loadChecklistData() async {
    setState(() => _isLoading = true);
    try {
      _hasExistingCheckin = _ticket.checkinChecklist?.exists ?? false;
    } finally {
      setState(() => _isLoading = false);
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
      // Agregar fecha y hora al momento de enviar
      _checklistData['fecha'] = DateTime.now().toString().split(' ')[0];
      
      // Convertir kilometraje a double si existe
      if (_checklistData['kilometraje_final'] != null) {
        final km = _checklistData['kilometraje_final'];
        if (km is String) {
          _checklistData['kilometraje_final'] = double.tryParse(km);
        }
      }

      // Enviar a la API
      final response = await _checkinService.submitCheckin(
        ticketId: _ticket.id,
        checklistData: _checklistData,
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
        Navigator.pop(context, true);
      } else {
        String errorMsg = response.message;
        if (response.errors != null) {
          final errors = response.errors!.values.join('\n');
          errorMsg = '$errorMsg\n\n$errors';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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
            if (_ticket.checkoutChecklist != null)
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Datos precargados desde el check-out',
                        style: TextStyle(color: Colors.blue.shade700),
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
                    value: _ticket.folio.toString(),
                    onChanged: (_) {},
                  ),
                  FormInputWidget(
                    label: 'Destino',
                    value: _ticket.destination ?? '',
                    onChanged: (v) => setState(() => _ticket = _ticket),
                  ),
                  FormInputWidget(
                    label: 'Modelo',
                    value: _ticket.vehicle?.model ?? '',
                    onChanged: (v) => setState(() => _ticket = _ticket),
                  ),
                  FormInputWidget(
                    label: 'Placas',
                    value: _ticket.vehicle?.plates ?? '',
                    onChanged: (v) => setState(() => _ticket = _ticket),
                  ),
                  FormInputWidget(
                    label: 'Marca',
                    value: _ticket.vehicle?.brand ?? '',
                    onChanged: (v) => setState(() => _ticket = _ticket),
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
                    value: _checklistData['hora_entrada']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['hora_entrada'] = v),
                  ),
                  FormInputWidget(
                    label: 'Kilometraje Final',
                    hint: 'Kilometraje al regreso',
                    value: _checklistData['kilometraje_final']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['kilometraje_final'] = v),
                  ),
                  FormInputWidget(
                    label: 'Combustible Final',
                    hint: '1/2, 3/4, etc',
                    value: _checklistData['nivel_combustible_final']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['nivel_combustible_final'] = v),
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
                        value: _checklistData['llanta_delantera_derecha'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_delantera_derecha'] = !(_checklistData['llanta_delantera_derecha'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Delantera Izquierda',
                        value: _checklistData['llanta_delantera_izquierda'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_delantera_izquierda'] = !(_checklistData['llanta_delantera_izquierda'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Delantera Vida',
                        value: _checklistData['llanta_delantera_vida'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_delantera_vida'] = !(_checklistData['llanta_delantera_vida'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Trasera Derecha',
                        value: _checklistData['llanta_trasera_derecha'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_trasera_derecha'] = !(_checklistData['llanta_trasera_derecha'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Trasera Izquierda',
                        value: _checklistData['llanta_trasera_izquierda'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_trasera_izquierda'] = !(_checklistData['llanta_trasera_izquierda'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Trasera Vida',
                        value: _checklistData['llanta_trasera_vida'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_trasera_vida'] = !(_checklistData['llanta_trasera_vida'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Refacción',
                        value: _checklistData['llanta_refaccion'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['llanta_refaccion'] = !(_checklistData['llanta_refaccion'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Presión Adecuada',
                        value: _checklistData['presion_adecuada'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['presion_adecuada'] = !(_checklistData['presion_adecuada'] ?? true)),
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
                        value: _checklistData['parabrisas'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['parabrisas'] = !(_checklistData['parabrisas'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Cofre',
                        value: _checklistData['cofre'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['cofre'] = !(_checklistData['cofre'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Parrilla',
                        value: _checklistData['parrilla'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['parrilla'] = !(_checklistData['parrilla'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Defensas',
                        value: _checklistData['defensas'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['defensas'] = !(_checklistData['defensas'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Molduras',
                        value: _checklistData['molduras'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['molduras'] = !(_checklistData['molduras'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Placa',
                        value: _checklistData['placa'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['placa'] = !(_checklistData['placa'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Salpicadera',
                        value: _checklistData['salpicadera'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['salpicadera'] = !(_checklistData['salpicadera'] ?? true)),
                      ),
                      ChecklistCheckboxWidget(
                        label: 'Antena',
                        value: _checklistData['antena'] ?? true,
                        onChanged: (_) => setState(() => _checklistData['antena'] = !(_checklistData['antena'] ?? true)),
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
                      ChecklistCheckboxWidget(label: 'Intermitentes', value: _checklistData['intermitentes'] ?? true, onChanged: (_) => setState(() => _checklistData['intermitentes'] = !(_checklistData['intermitentes'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Direc. Der', value: _checklistData['direccional_derecha'] ?? true, onChanged: (_) => setState(() => _checklistData['direccional_derecha'] = !(_checklistData['direccional_derecha'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Direc. Izq', value: _checklistData['direccional_izquierda'] ?? true, onChanged: (_) => setState(() => _checklistData['direccional_izquierda'] = !(_checklistData['direccional_izquierda'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Luz Stop', value: _checklistData['luz_stop'] ?? true, onChanged: (_) => setState(() => _checklistData['luz_stop'] = !(_checklistData['luz_stop'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Faros', value: _checklistData['faros'] ?? true, onChanged: (_) => setState(() => _checklistData['faros'] = !(_checklistData['faros'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Luces Altas', value: _checklistData['luces_altas'] ?? true, onChanged: (_) => setState(() => _checklistData['luces_altas'] = !(_checklistData['luces_altas'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Luz Interior', value: _checklistData['luz_interior'] ?? true, onChanged: (_) => setState(() => _checklistData['luz_interior'] = !(_checklistData['luz_interior'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Calaveras', value: _checklistData['calaveras_buen_estado'] ?? true, onChanged: (_) => setState(() => _checklistData['calaveras_buen_estado'] = !(_checklistData['calaveras_buen_estado'] ?? true))),
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
                      ChecklistCheckboxWidget(label: 'Mata Chispas', value: _checklistData['mata_chispas'] ?? true, onChanged: (_) => setState(() => _checklistData['mata_chispas'] = !(_checklistData['mata_chispas'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Alarma', value: _checklistData['alarma'] ?? true, onChanged: (_) => setState(() => _checklistData['alarma'] = !(_checklistData['alarma'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Extintor', value: _checklistData['extintor'] ?? true, onChanged: (_) => setState(() => _checklistData['extintor'] = !(_checklistData['extintor'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Botiquín', value: _checklistData['botiquin'] ?? true, onChanged: (_) => setState(() => _checklistData['botiquin'] = !(_checklistData['botiquin'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Tarjeta Circ', value: _checklistData['tarjeta_circulacion'] ?? true, onChanged: (_) => setState(() => _checklistData['tarjeta_circulacion'] = !(_checklistData['tarjeta_circulacion'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Licencia', value: _checklistData['licencia_conducir_vigente'] ?? true, onChanged: (_) => setState(() => _checklistData['licencia_conducir_vigente'] = !(_checklistData['licencia_conducir_vigente'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Póliza Seg', value: _checklistData['poliza_seguro'] ?? true, onChanged: (_) => setState(() => _checklistData['poliza_seguro'] = !(_checklistData['poliza_seguro'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Triángulo', value: _checklistData['triangulo_emergencia'] ?? true, onChanged: (_) => setState(() => _checklistData['triangulo_emergencia'] = !(_checklistData['triangulo_emergencia'] ?? true))),
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
                      ChecklistCheckboxWidget(label: 'Tablero', value: _checklistData['tablero_indicadores'] ?? true, onChanged: (_) => setState(() => _checklistData['tablero_indicadores'] = !(_checklistData['tablero_indicadores'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Switch', value: _checklistData['switch_encendido'] ?? true, onChanged: (_) => setState(() => _checklistData['switch_encendido'] = !(_checklistData['switch_encendido'] ?? true))),
                      ChecklistCheckboxWidget(label: 'A/C', value: _checklistData['controles_ac'] ?? true, onChanged: (_) => setState(() => _checklistData['controles_ac'] = !(_checklistData['controles_ac'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Defroster', value: _checklistData['defroster'] ?? true, onChanged: (_) => setState(() => _checklistData['defroster'] = !(_checklistData['defroster'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Radio', value: _checklistData['radio'] ?? true, onChanged: (_) => setState(() => _checklistData['radio'] = !(_checklistData['radio'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Volante', value: _checklistData['volante'] ?? true, onChanged: (_) => setState(() => _checklistData['volante'] = !(_checklistData['volante'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Bolsas Aire', value: _checklistData['bolsas_aire'] ?? true, onChanged: (_) => setState(() => _checklistData['bolsas_aire'] = !(_checklistData['bolsas_aire'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Cinturón', value: _checklistData['cintulon_seguridad'] ?? true, onChanged: (_) => setState(() => _checklistData['cintulon_seguridad'] = !(_checklistData['cintulon_seguridad'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Coderas', value: _checklistData['coderas'] ?? true, onChanged: (_) => setState(() => _checklistData['coderas'] = !(_checklistData['coderas'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Espejo', value: _checklistData['espejo_interior'] ?? true, onChanged: (_) => setState(() => _checklistData['espejo_interior'] = !(_checklistData['espejo_interior'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Freno Mano', value: _checklistData['freno_mano'] ?? true, onChanged: (_) => setState(() => _checklistData['freno_mano'] = !(_checklistData['freno_mano'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Encendedor', value: _checklistData['encendedor'] ?? true, onChanged: (_) => setState(() => _checklistData['encendedor'] = !(_checklistData['encendedor'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Guantera', value: _checklistData['guantera'] ?? true, onChanged: (_) => setState(() => _checklistData['guantera'] = !(_checklistData['guantera'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Manijas', value: _checklistData['manijas_interiores'] ?? true, onChanged: (_) => setState(() => _checklistData['manijas_interiores'] = !(_checklistData['manijas_interiores'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Seguros', value: _checklistData['seguros'] ?? true, onChanged: (_) => setState(() => _checklistData['seguros'] = !(_checklistData['seguros'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Asientos', value: _checklistData['asientos'] ?? true, onChanged: (_) => setState(() => _checklistData['asientos'] = !(_checklistData['asientos'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Tapetes', value: _checklistData['tapetes_delanteros_traseros'] ?? true, onChanged: (_) => setState(() => _checklistData['tapetes_delanteros_traseros'] = !(_checklistData['tapetes_delanteros_traseros'] ?? true))),
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
                      ChecklistCheckboxWidget(label: 'Aceite Motor', value: _checklistData['nivel_aceite_motor'] ?? true, onChanged: (_) => setState(() => _checklistData['nivel_aceite_motor'] = !(_checklistData['nivel_aceite_motor'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Anticongelante', value: _checklistData['nivel_anticongelante'] ?? true, onChanged: (_) => setState(() => _checklistData['nivel_anticongelante'] = !(_checklistData['nivel_anticongelante'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Líquido Frenos', value: _checklistData['nivel_liquido_frenos'] ?? true, onChanged: (_) => setState(() => _checklistData['nivel_liquido_frenos'] = !(_checklistData['nivel_liquido_frenos'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Batería', value: _checklistData['bateria'] ?? true, onChanged: (_) => setState(() => _checklistData['bateria'] = !(_checklistData['bateria'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Bayoneta', value: _checklistData['bayoneta_aceite_motor'] ?? true, onChanged: (_) => setState(() => _checklistData['bayoneta_aceite_motor'] = !(_checklistData['bayoneta_aceite_motor'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Tapones', value: _checklistData['tapones'] ?? true, onChanged: (_) => setState(() => _checklistData['tapones'] = !(_checklistData['tapones'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Claxon', value: _checklistData['bocina_claxon'] ?? true, onChanged: (_) => setState(() => _checklistData['bocina_claxon'] = !(_checklistData['bocina_claxon'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Radiador', value: _checklistData['radiador'] ?? true, onChanged: (_) => setState(() => _checklistData['radiador'] = !(_checklistData['radiador'] ?? true))),
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
                      ChecklistCheckboxWidget(label: 'Gato', value: _checklistData['gato'] ?? true, onChanged: (_) => setState(() => _checklistData['gato'] = !(_checklistData['gato'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Llave Llantas', value: _checklistData['llave_ruedas'] ?? true, onChanged: (_) => setState(() => _checklistData['llave_ruedas'] = !(_checklistData['llave_ruedas'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Cables Corriente', value: _checklistData['cables_pasa_corriente'] ?? true, onChanged: (_) => setState(() => _checklistData['cables_pasa_corriente'] = !(_checklistData['cables_pasa_corriente'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Caja Herr', value: _checklistData['caja_bolsa_herramientas'] ?? true, onChanged: (_) => setState(() => _checklistData['caja_bolsa_herramientas'] = !(_checklistData['caja_bolsa_herramientas'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Birlo Seg', value: _checklistData['dado_birlo_seguridad'] ?? true, onChanged: (_) => setState(() => _checklistData['dado_birlo_seguridad'] = !(_checklistData['dado_birlo_seguridad'] ?? true))),
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
                      ChecklistCheckboxWidget(label: 'Permisos', value: _checklistData['calcomanias_permisos'] ?? true, onChanged: (_) => setState(() => _checklistData['calcomanias_permisos'] = !(_checklistData['calcomanias_permisos'] ?? true))),
                      ChecklistCheckboxWidget(label: 'Veloc Máx', value: _checklistData['calcomania_velocidad_maxima'] ?? true, onChanged: (_) => setState(() => _checklistData['calcomania_velocidad_maxima'] = !(_checklistData['calcomania_velocidad_maxima'] ?? true))),
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
                        _checklistData['condicion_carroceria_imagen'] = base64Image;
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
                description: 'Registra mantenimiento y responsables',
                children: [
                  FormInputWidget(
                    label: 'Mantenimiento Preventivo',
                    hint: 'Describe tareas preventivas...',
                    value: _checklistData['mantenimiento_preventivo']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['mantenimiento_preventivo'] = v),
                    maxLines: 3,
                  ),
                  FormInputWidget(
                    label: 'Mantenimiento Correctivo',
                    hint: 'Describe reparaciones realizadas...',
                    value: _checklistData['mantenimiento_correctivo']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['mantenimiento_correctivo'] = v),
                    maxLines: 3,
                  ),
                  FormInputWidget(
                    label: 'Responsable Recibo',
                    hint: 'Nombre de quién recibe',
                    value: _checklistData['responsable_recibo_uso']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['responsable_recibo_uso'] = v),
                  ),
                  FormInputWidget(
                    label: 'Responsable Entrega',
                    hint: 'Nombre de quién entrega',
                    value: _checklistData['responsable_entrega']?.toString() ?? '',
                    onChanged: (v) => setState(() => _checklistData['responsable_entrega'] = v),
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
