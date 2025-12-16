import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/ticket_model.dart';
import '../../widgets/user_appbar_widget.dart';
import '../auth/login_screen.dart';
import 'widgets/ticket_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  String? _userEmail;
  String? _photoUrl;
  String? _userName;
  bool _isLoading = true;
  bool _isSyncing = false;
  List<TicketModel> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTickets();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await _authService.getUser();

      setState(() {
        _userEmail = user?.email ?? 'Usuario';
        _photoUrl = user?.photoUrl;
        _userName = user?.displayName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userEmail = 'Usuario';
        _photoUrl = null;
        _isLoading = false;
      });
    }
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

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        elevation: 0,
        backgroundColor: scheme.primary,
        leadingWidth: 280,
        actions: [
          UserAppBarWidget(
            userName: _userName,
            userEmail: _userEmail,
            photoUrl: _photoUrl,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay tickets registrados',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadTickets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                    child: Text("Tickets disponibles: ${_tickets.length}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return TicketCardWidget(ticket: ticket);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
