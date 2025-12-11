import 'package:flutter/material.dart';
import '../../models/ticket_request.dart';
import 'widgets/form_section_widget.dart';
import 'widgets/form_input_widget.dart';
import 'widgets/form_toggle_widget.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 4;

  // Form data
  String _destination = '';
  String _client = '';
  DateTime _requestedDate = DateTime.now();
  String _requestedTimeStart = '';
  String _requestedTimeEnd = '';
  String _purpose = '';
  bool _requiresReturn = false;
  String _vehicleType = 'auto';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _requestedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _requestedDate) {
      setState(() {
        _requestedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          _requestedTimeStart = timeString;
        } else {
          _requestedTimeEnd = timeString;
        }
      });
    }
  }

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
    // Scroll to top animation
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final ticket = TicketRequest(
        destination: _destination,
        client: _client.isNotEmpty ? _client : null,
        requestedDate: _requestedDate,
        requestedTimeStart: _requestedTimeStart,
        requestedTimeEnd: _requiresReturn ? _requestedTimeEnd : null,
        purpose: _purpose,
        requiresReturn: _requiresReturn,
        vehicleType: _vehicleType,
      );

      // TODO: Enviar a API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requisición creada correctamente'),
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
        title: const Text('Nueva Requisición'),
        backgroundColor: scheme.primary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Step 1: Información básica
              if (_currentStep == 1)
                FormSectionWidget(
                  step: 1,
                  totalSteps: _totalSteps,
                  title: 'Información del Viaje',
                  description: 'Cuéntanos a dónde necesitas ir',
                  children: [
                    FormInputWidget(
                      label: 'Destino',
                      hint: 'Ej: Centro Comercial La Vega',
                      value: _destination,
                      onChanged: (value) => setState(() => _destination = value),
                      required: true,
                      prefixIcon: const Icon(Icons.location_on),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'El destino es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormInputWidget(
                      label: 'Cliente (Opcional)',
                      hint: 'Ej: Empresa XYZ',
                      value: _client,
                      onChanged: (value) => setState(() => _client = value),
                      prefixIcon: const Icon(Icons.business),
                    ),
                  ],
                ),

              // Step 2: Fechas y Horas
              if (_currentStep == 2)
                FormSectionWidget(
                  step: 2,
                  totalSteps: _totalSteps,
                  title: 'Fechas y Horas',
                  description: 'Especifica cuándo y a qué hora',
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: FormInputWidget(
                        label: 'Fecha de Salida',
                        value: _requestedDate.toString().split(' ')[0],
                        onChanged: (_) {},
                        required: true,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: FormInputWidget(
                        label: 'Hora de Salida',
                        value: _requestedTimeStart,
                        onChanged: (_) {},
                        required: true,
                        prefixIcon: const Icon(Icons.schedule),
                        hint: 'HH:MM',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_requiresReturn)
                      GestureDetector(
                        onTap: () => _selectTime(context, false),
                        child: FormInputWidget(
                          label: 'Hora de Regreso',
                          value: _requestedTimeEnd,
                          onChanged: (_) {},
                          prefixIcon: const Icon(Icons.schedule),
                          hint: 'HH:MM',
                        ),
                      ),
                  ],
                ),

              // Step 3: Detalles adicionales
              if (_currentStep == 3)
                FormSectionWidget(
                  step: 3,
                  totalSteps: _totalSteps,
                  title: 'Detalles del Viaje',
                  description: 'Información importante sobre tu requisición',
                  children: [
                    FormInputWidget(
                      label: 'Propósito del Viaje',
                      hint: 'Ej: Visita a cliente, entrega de mercancía...',
                      value: _purpose,
                      onChanged: (value) => setState(() => _purpose = value),
                      maxLines: 3,
                      required: true,
                      prefixIcon: const Icon(Icons.description),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'El propósito es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FormToggleWidget(
                      label: '¿Requiere Regreso?',
                      description: 'Indica si necesitas que te traigan de vuelta',
                      value: _requiresReturn,
                      onChanged: (value) => setState(() => _requiresReturn = value),
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de Vehículo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildVehicleOption('auto', 'Auto', Icons.directions_car),
                            _buildVehicleOption('camioneta', 'Camioneta', Icons.local_shipping),
                            _buildVehicleOption('taxi', 'Taxi', Icons.local_taxi),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

              // Step 4: Confirmación
              if (_currentStep == 4)
                FormSectionWidget(
                  step: 4,
                  totalSteps: _totalSteps,
                  title: 'Resumen',
                  description: 'Revisa los detalles antes de enviar',
                  children: [
                    _buildSummaryCard('Destino', _destination),
                    if (_client.isNotEmpty) _buildSummaryCard('Cliente', _client),
                    _buildSummaryCard('Fecha', _requestedDate.toString().split(' ')[0]),
                    _buildSummaryCard('Hora de Salida', _requestedTimeStart),
                    if (_requiresReturn) _buildSummaryCard('Hora de Regreso', _requestedTimeEnd ?? '-'),
                    _buildSummaryCard('Propósito', _purpose),
                    _buildSummaryCard('Tipo de Vehículo', _vehicleType.toUpperCase()),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: scheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: scheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tu requisición será enviada para aprobación',
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // Botones
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
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
                            onPressed: _currentStep == _totalSteps ? _submitForm : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _currentStep == _totalSteps ? 'Enviar Requisición' : 'Siguiente',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
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

  Widget _buildVehicleOption(String value, String label, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _vehicleType == value;

    return InkWell(
      onTap: () => setState(() => _vehicleType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? scheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? scheme.primaryContainer.withOpacity(0.2) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? scheme.primary : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? scheme.primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
