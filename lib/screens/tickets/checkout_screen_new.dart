import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';
import 'widgets/form_section_widget.dart';
import 'widgets/form_input_widget.dart';
import 'widgets/checklist_checkbox_widget.dart';
import 'widgets/vehicle_damage_canvas_widget.dart';

class CheckoutScreenNew extends StatefulWidget {
  const CheckoutScreenNew({super.key});

  @override
  State<CheckoutScreenNew> createState() => _CheckoutScreenNewState();
}

class _CheckoutScreenNewState extends State<CheckoutScreenNew> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 12;

  late ChecklistModel _checklist;
  String _condicionCarroceriaImagen = ''; // Base64 de imagen con daños
  
  // Mapa mutable para los valores de los checkboxes
  final Map<String, bool> _checkboxValues = {};
  
  @override
  void initState() {
    super.initState();
    _checklist = ChecklistModel(
      ticketId: 1,
      tipoInspeccion: 'salida',
      folio: 1,
      fecha: DateTime.now().toString().split(' ')[0],
      destino: 'Centro Comercial',
      modelo: 'Corolla',
      placas: 'ABC-123',
      marca: 'Toyota',
      kilometrajeInicial: 0,
      nivelCombustibleInicial: '1/2',
    );
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
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
        llantaDelanteraDerechaOk: _checklist.llantaDelanteraDerechaOk,
        llantaDelanteraIzquierdaOk: _checklist.llantaDelanteraIzquierdaOk,
        llantaDelanteraVidaOk: _checklist.llantaDelanteraVidaOk,
        llantaTrseraDerechaOk: _checklist.llantaTrseraDerechaOk,
        llantaTraseraIzquierdaOk: _checklist.llantaTraseraIzquierdaOk,
        llantaTraseraVidaOk: _checklist.llantaTraseraVidaOk,
        llantaRefaccionOk: _checklist.llantaRefaccionOk,
        presionAdecuadaOk: _checklist.presionAdecuadaOk,
        parabrisisOk: _checklist.parabrisisOk,
        cofreOk: _checklist.cofreOk,
        parrillaOk: _checklist.parrillaOk,
        defensasOk: _checklist.defensasOk,
        moldurasOk: _checklist.moldurasOk,
        placaOk: _checklist.placaOk,
        salpicaderaOk: _checklist.salpicaderaOk,
        antenaOk: _checklist.antenaOk,
        intermitentesOk: _checklist.intermitentesOk,
        direccionalDerechaOk: _checklist.direccionalDerechaOk,
        direccionalIzquierdaOk: _checklist.direccionalIzquierdaOk,
        luzStopOk: _checklist.luzStopOk,
        farosOk: _checklist.farosOk,
        lucesAltasOk: _checklist.lucesAltasOk,
        luzInteriorOk: _checklist.luzInteriorOk,
        calaveras: _checklist.calaveras,
        mataChispassOk: _checklist.mataChispassOk,
        alarmaOk: _checklist.alarmaOk,
        extintorOk: _checklist.extintorOk,
        botiquinOk: _checklist.botiquinOk,
        tarjetaCirculacionOk: _checklist.tarjetaCirculacionOk,
        licenciaConducirVigenteOk: _checklist.licenciaConducirVigenteOk,
        polizaSeguroOk: _checklist.polizaSeguroOk,
        trianguloEmergenciaOk: _checklist.trianguloEmergenciaOk,
        tableroIndicadoresOk: _checklist.tableroIndicadoresOk,
        switchEncendidoOk: _checklist.switchEncendidoOk,
        controlesAcOk: _checklist.controlesAcOk,
        defrosterOk: _checklist.defrosterOk,
        radioOk: _checklist.radioOk,
        volanteOk: _checklist.volanteOk,
        bolsasAireOk: _checklist.bolsasAireOk,
        cinturonSeguridadOk: _checklist.cinturonSeguridadOk,
        coderasOk: _checklist.coderasOk,
        espejoInteriorOk: _checklist.espejoInteriorOk,
        frenoManoOk: _checklist.frenoManoOk,
        encendedorOk: _checklist.encendedorOk,
        guanteraOk: _checklist.guanteraOk,
        manijasInterioresOk: _checklist.manijasInterioresOk,
        segurosOk: _checklist.segurosOk,
        asientosOk: _checklist.asientosOk,
        tapetesOk: _checklist.tapetesOk,
        nivelAceiteMotorOk: _checklist.nivelAceiteMotorOk,
        nivelAnticongelanteOk: _checklist.nivelAnticongelanteOk,
        nivelLiquidoFrenosOk: _checklist.nivelLiquidoFrenosOk,
        bateriaOk: _checklist.bateriaOk,
        bayonetaAceiteOk: _checklist.bayonetaAceiteOk,
        taponesOk: _checklist.taponesOk,
        bocinaClaxxonOk: _checklist.bocinaClaxxonOk,
        radiadorOk: _checklist.radiadorOk,
        gatoOk: _checklist.gatoOk,
        llaveLlantasOk: _checklist.llaveLlantasOk,
        cablesPasaCorrienteOk: _checklist.cablesPasaCorrienteOk,
        cajaHerramientasOk: _checklist.cajaHerramientasOk,
        dadoBirloSeguidadOk: _checklist.dadoBirloSeguidadOk,
        calcomaniastPermisosOk: _checklist.calcomaniastPermisosOk,
        calcomaniaVelocidadMaximaOk: _checklist.calcomaniaVelocidadMaximaOk,
        condicionCarroceriaImagen: _condicionCarroceriaImagen, // Agregar imagen de daños
      );

      // Preparar datos para enviar
      final checklistJson = checklistCompleto.toJson();
      
      // Log de los datos que se enviarían
      print('Datos checklist: ${checklistJson.keys.join(', ')}');
      print('Imagen guardada: ${_condicionCarroceriaImagen.isNotEmpty ? 'Sí' : 'No'}');
      print('Tamaño imagen (caracteres): ${_condicionCarroceriaImagen.length}');

      // TODO: Enviar POST request a tu API
      // await _submitChecklistToAPI(checklistJson);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout completado'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
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
        title: const Text('Checkout'),
        backgroundColor: scheme.primary,
      ),
      body: Form(
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
                        onPressed: _currentStep == _totalSteps ? _submit : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
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
      ),
    );
  }
}
