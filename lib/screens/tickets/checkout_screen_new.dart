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

  late ChecklistModel _checklist;  String _condicionCarroceriaImagen = ''; // Base64 de imagen con daños
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
                          value: _checklist.llantaDelanteraDerechaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Delantera Izq',
                          value: _checklist.llantaDelanteraIzquierdaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Delantera Vida',
                          value: _checklist.llantaDelanteraVidaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Trasera Derecha',
                          value: _checklist.llantaTrseraDerechaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Trasera Izq',
                          value: _checklist.llantaTraseraIzquierdaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Trasera Vida',
                          value: _checklist.llantaTraseraVidaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Refacción',
                          value: _checklist.llantaRefaccionOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Presión OK',
                          value: _checklist.presionAdecuadaOk,
                          onChanged: (v) => setState(() {}),
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
                          value: _checklist.parabrisisOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Cofre',
                          value: _checklist.cofreOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Parrilla',
                          value: _checklist.parrillaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Defensas',
                          value: _checklist.defensasOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Molduras',
                          value: _checklist.moldurasOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Placa',
                          value: _checklist.placaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Salpicadera',
                          value: _checklist.salpicaderaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Antena',
                          value: _checklist.antenaOk,
                          onChanged: (v) => setState(() {}),
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
                          value: _checklist.intermitentesOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Direccional Der',
                          value: _checklist.direccionalDerechaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Direccional Izq',
                          value: _checklist.direccionalIzquierdaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Luz Stop',
                          value: _checklist.luzStopOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Faros',
                          value: _checklist.farosOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Luces Altas',
                          value: _checklist.lucesAltasOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Luz Interior',
                          value: _checklist.luzInteriorOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Calaveras',
                          value: _checklist.calaveras,
                          onChanged: (v) => setState(() {}),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChecklistCheckboxWidget(
                          label: 'Mata\nChispas',
                          value: _checklist.mataChispassOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Alarma',
                          value: _checklist.alarmaOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Extintor',
                          value: _checklist.extintorOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Botiquín',
                          value: _checklist.botiquinOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Tarjeta\nCirculación',
                          value: _checklist.tarjetaCirculacionOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Licencia\nVigente',
                          value: _checklist.licenciaConducirVigenteOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Póliza\nSeguro',
                          value: _checklist.polizaSeguroOk,
                          onChanged: (v) => setState(() {}),
                        ),
                        ChecklistCheckboxWidget(
                          label: 'Triángulo\nEmergencia',
                          value: _checklist.trianguloEmergenciaOk,
                          onChanged: (v) => setState(() {}),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChecklistCheckboxWidget(label: 'Tablero', value: _checklist.tableroIndicadoresOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Switch', value: _checklist.switchEncendidoOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'AC', value: _checklist.controlesAcOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Defroster', value: _checklist.defrosterOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Radio', value: _checklist.radioOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Volante', value: _checklist.volanteOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Bolsas\nAire', value: _checklist.bolsasAireOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Cinturón', value: _checklist.cinturonSeguridadOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Coderas', value: _checklist.coderasOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Espejo', value: _checklist.espejoInteriorOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Freno\nMano', value: _checklist.frenoManoOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Encendedor', value: _checklist.encendedorOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Guantera', value: _checklist.guanteraOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Manijas', value: _checklist.manijasInterioresOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Seguros', value: _checklist.segurosOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Asientos', value: _checklist.asientosOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Tapetes', value: _checklist.tapetesOk, onChanged: (v) => setState(() {})),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChecklistCheckboxWidget(label: 'Aceite', value: _checklist.nivelAceiteMotorOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Anticongelante', value: _checklist.nivelAnticongelanteOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Frenos', value: _checklist.nivelLiquidoFrenosOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Batería', value: _checklist.bateriaOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Bayoneta', value: _checklist.bayonetaAceiteOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Tapones', value: _checklist.taponesOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Claxon', value: _checklist.bocinaClaxxonOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Radiador', value: _checklist.radiadorOk, onChanged: (v) => setState(() {})),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChecklistCheckboxWidget(label: 'Gato', value: _checklist.gatoOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Llave\nRuedas', value: _checklist.llaveLlantasOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Cables\nCorriente', value: _checklist.cablesPasaCorrienteOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Caja\nHerramientas', value: _checklist.cajaHerramientasOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Birlo\nSeguridad', value: _checklist.dadoBirloSeguidadOk, onChanged: (v) => setState(() {})),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChecklistCheckboxWidget(label: 'Permisos', value: _checklist.calcomaniastPermisosOk, onChanged: (v) => setState(() {})),
                        ChecklistCheckboxWidget(label: 'Velocidad\nMáxima', value: _checklist.calcomaniaVelocidadMaximaOk, onChanged: (v) => setState(() {})),
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
