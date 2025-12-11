import 'package:flutter/material.dart';
import 'widgets/form_section_widget.dart';
import 'widgets/form_input_widget.dart';
import 'widgets/form_toggle_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Datos
  String _odometerStart = '';
  String _odometerEnd = '';
  double _fuelStart = 50;
  double _fuelEnd = 50;
  bool _tiresOk = true;
  bool _lightsOk = true;
  bool _toolsOk = true;
  bool _fluidsOk = true;
  String _notes = '';

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      _scrollToTop();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    // Placeholder for scroll controller if needed
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout enviado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: scheme.primary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Paso 1: Datos básicos
              if (_currentStep == 1)
                FormSectionWidget(
                  step: 1,
                  totalSteps: _totalSteps,
                  title: 'Datos del vehículo',
                  description: 'Registra odómetro y combustible',
                  children: [
                    FormInputWidget(
                      label: 'Kilometraje inicial',
                      hint: 'Ej: 12000',
                      value: _odometerStart,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => _odometerStart = v),
                      required: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    FormInputWidget(
                      label: 'Kilometraje final',
                      hint: 'Ej: 12100',
                      value: _odometerEnd,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => _odometerEnd = v),
                      required: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    _fuelSlider('Combustible inicial', (val) => setState(() => _fuelStart = val), _fuelStart, scheme.primary),
                    _fuelSlider('Combustible final', (val) => setState(() => _fuelEnd = val), _fuelEnd, scheme.secondary),
                  ],
                ),

              // Paso 2: Estado general
              if (_currentStep == 2)
                FormSectionWidget(
                  step: 2,
                  totalSteps: _totalSteps,
                  title: 'Estado del vehículo',
                  description: 'Verifica llantas, luces, fluidos y herramientas',
                  children: [
                    FormToggleWidget(
                      label: 'Llantas en buen estado',
                      description: 'Sin daños visibles, presión adecuada',
                      value: _tiresOk,
                      onChanged: (v) => setState(() => _tiresOk = v),
                      icon: Icons.tire_repair,
                    ),
                    FormToggleWidget(
                      label: 'Luces funcionales',
                      description: 'Bajas, altas, direccionales y freno',
                      value: _lightsOk,
                      onChanged: (v) => setState(() => _lightsOk = v),
                      icon: Icons.light_mode,
                    ),
                    FormToggleWidget(
                      label: 'Fluidos revisados',
                      description: 'Aceite, refrigerante, freno',
                      value: _fluidsOk,
                      onChanged: (v) => setState(() => _fluidsOk = v),
                      icon: Icons.water_drop,
                    ),
                    FormToggleWidget(
                      label: 'Herramientas completas',
                      description: 'Gato, llave, refacción',
                      value: _toolsOk,
                      onChanged: (v) => setState(() => _toolsOk = v),
                      icon: Icons.home_repair_service,
                    ),
                  ],
                ),

              // Paso 3: Daños y notas
              if (_currentStep == 3)
                FormSectionWidget(
                  step: 3,
                  totalSteps: _totalSteps,
                  title: 'Daños y notas',
                  description: 'Describe daños, incidencias o comentarios',
                  children: [
                    FormInputWidget(
                      label: 'Notas / Daños',
                      hint: 'Describe daños o incidencias...',
                      value: _notes,
                      onChanged: (v) => setState(() => _notes = v),
                      maxLines: 4,
                    ),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 1)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
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
                          _currentStep == _totalSteps ? 'Enviar Checkout' : 'Siguiente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _fuelSlider(String label, ValueChanged<double> onChanged, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.local_gas_station, size: 16, color: Colors.grey),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                divisions: 10,
                label: '${value.toStringAsFixed(0)}%',
                activeColor: color,
                onChanged: onChanged,
              ),
            ),
            Text('${value.toStringAsFixed(0)}%'),
          ],
        ),
      ],
    );
  }
}
