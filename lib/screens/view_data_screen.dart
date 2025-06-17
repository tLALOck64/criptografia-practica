import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/secure_storage_service.dart';
import '../services/encryption_service.dart';
import '../utils/constants.dart';

class ViewDataScreen extends StatefulWidget {
  const ViewDataScreen({Key? key}) : super(key: key);

  @override
  State<ViewDataScreen> createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final EncryptionService _encryptionService = EncryptionService();
  final TextEditingController _privateKeyController = TextEditingController();
  
  bool _isLoading = true;
  String _encryptedData = '';
  Map<String, dynamic> _decryptedData = {};
  bool _isDecrypted = false;
  bool _showPassword = false;
  String? _decryptError;

  @override
  void initState() {
    super.initState();
    _loadEncryptedData();
  }

  Future<void> _loadEncryptedData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar los datos cifrados
      final encryptedData = await _secureStorage.readSecureData(AppConstants.encryptedDataKey);
      
      setState(() {
        _encryptedData = encryptedData ?? 'No hay datos cifrados';
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _decryptData() async {
    if (_privateKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa la clave privada')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _decryptError = null;
    });

    try {
      // Descifrar los datos
      final decryptedText = _encryptionService.decryptData(
        _encryptedData, 
        _privateKeyController.text
      );
      
      if (decryptedText.startsWith('Error')) {
        setState(() {
          _decryptError = 'Clave privada incorrecta o datos corruptos';
          _isDecrypted = false;
          _isLoading = false;
        });
        return;
      }
      
      // Convertir el JSON a un mapa
      final Map<String, dynamic> userData = jsonDecode(decryptedText);
      
      setState(() {
        _decryptedData = userData;
        _isDecrypted = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _decryptError = 'Error al descifrar: $e';
        _isDecrypted = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Almacenados'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _encryptedData == 'No hay datos cifrados'
              ? const Center(
                  child: Text(
                    'No hay datos almacenados',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos Cifrados',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEncryptedDataCard(),
                      const SizedBox(height: 24),
                      if (!_isDecrypted) ...[
                        const Text(
                          'Ingresa tu clave privada para descifrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _privateKeyController,
                          decoration: const InputDecoration(
                            labelText: 'Clave Privada',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.key),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _decryptData,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            AppConstants.decryptButtonText,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        if (_decryptError != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _decryptError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                      if (_isDecrypted) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Datos Descifrados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDataCard(
                          'Nombre',
                          _decryptedData['nombre'] ?? 'No disponible',
                          Icons.person,
                        ),
                        const SizedBox(height: 12),
                        _buildDataCard(
                          'Edad',
                          _decryptedData['edad'] ?? 'No disponible',
                          Icons.calendar_today,
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordCard(),
                        const SizedBox(height: 12),
                        _buildDataCard(
                          'Matrícula',
                          _decryptedData['matricula'] ?? 'No disponible',
                          Icons.school,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildEncryptedDataCard() {
    return Card(
      elevation: 4,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Datos Cifrados (AES)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _encryptedData,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.password, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              _showPassword
                  ? _decryptedData['contraseña'] ?? 'No disponible'
                  : '••••••••••',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }
} 