import 'package:flutter/material.dart';
import 'ticket_detail_screen.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../models/ticket_model.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<TicketModel> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar tickets del storage
      final tickets = await _storageService.getTickets();
      
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });

      // Intentar sincronizar en segundo plano
      _syncTicketsInBackground();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tickets: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Sincronizar tickets en segundo plano
  Future<void> _syncTicketsInBackground() async {
    try {
      final email = await _storageService.getUserEmail();
      final name = await _storageService.getUserName();

      if (email != null && name != null) {
        final result = await _authService.syncWithBackend(
          email: email,
          name: name,
        );

        if (result.success && mounted) {
          // Recargar tickets actualizados
          final tickets = await _storageService.getTickets();
          setState(() {
            _tickets = tickets;
          });
        }
      }
    } catch (e) {
      // Silenciar errores de sincronización en segundo plano
      debugPrint('Error en sincronización de tickets: $e');
    }
  }

  Map<String, dynamic> _getCurrentStatus(TicketModel ticket) {
    if (ticket.hasCheckout && ticket.hasCheckin) {
      return {
        'label': 'Completado',
        'icon': Icons.check_circle,
        'color': Colors.green,
      };
    } else if (ticket.hasCheckout) {
      return {
        'label': 'Check Out',
        'icon': Icons.exit_to_app,
        'color': Colors.orange,
      };
    } else {
      return {
        'label': 'Aprobado',
        'icon': Icons.check_circle_outline,
        'color': Colors.blue,
      };
    }
  }

  Widget _buildStatusChip(TicketModel ticket) {
    final status = _getCurrentStatus(ticket);
    final color = status['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status['icon'] as IconData,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status['label'] as String,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        backgroundColor: scheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay tickets registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¡Excelente! No tienes infracciones',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailScreen(
                                  ticket: ticket,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ticket.folio,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildStatusChip(ticket),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ticket.destination ?? 'Sin destino especificado',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        ticket.vehicleName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ticket.requestedDate?.toString().split(' ')[0] ?? 'Sin fecha',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (ticket.purpose != null && ticket.purpose!.isNotEmpty)
                                      Expanded(
                                        child: Text(
                                          ticket.purpose!,
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: scheme.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
