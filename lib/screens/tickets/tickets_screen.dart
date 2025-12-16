import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../models/ticket_model.dart';
import 'widgets/ticket_card_widget.dart';

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
      final tickets = await _storageService.getTickets();

      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
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
      print('Error en sincronización de tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
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
                  'No hay tickets disponibles',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
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
                return TicketCardWidget(ticket: ticket);
              },
            ),
          );
    return body;
  }
}
