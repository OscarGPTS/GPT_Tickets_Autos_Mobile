import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/user_appbar_widget.dart';
import '../auth/login_screen.dart';
import '../tickets/tickets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _userEmail;
  String? _photoUrl;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
          : const TicketsScreen(),
    );
  }
}
