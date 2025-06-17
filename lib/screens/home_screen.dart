import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../services/encryption_service.dart';
import '../utils/constants.dart';
import 'view_data_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final EncryptionService _encryptionService = EncryptionService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _privateKeyController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _checkForExistingData();
  }

  Future<void> _checkForExistingData() async {
    setState(() {
      _isLoading = true;
    });
    
    final hasEncryptedData = await _secureStorage.containsKey(AppConstants.encryptedDataKey);
    
    setState(() {
      _hasData = hasEncryptedData;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    // Validar campos obligatorios
    if (_nameController.text.isEmpty || 
        _ageController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _studentIdController.text.isEmpty ||
        _privateKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Crear un mapa con los datos del usuario
      final Map<String, String> userData = {
        'nombre': _nameController.text,
        'edad': _ageController.text,
        'contraseña': _passwordController.text,
        'matricula': _studentIdController.text,
      };
      
      // Convertir a JSON
      final String userDataJson = jsonEncode(userData);
      
      // Cifrar los datos con la clave privada
      final String encryptedData = _encryptionService.encryptData(
        userDataJson, 
        _privateKeyController.text
      );
      
      // Guardar los datos cifrados
      await _secureStorage.saveSecureData(
        AppConstants.encryptedDataKey, 
        encryptedData
      );
      
      // Guardar la clave privada (en una aplicación real, no deberías guardar la clave)
      await _secureStorage.saveSecureData(
        AppConstants.privateKeyKey, 
        _privateKeyController.text
      );
      
      setState(() {
        _hasData = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos cifrados y guardados correctamente')),
      );
      
      // Limpiar campos
      _nameController.clear();
      _ageController.clear();
      _passwordController.clear();
      _studentIdController.clear();
      _privateKeyController.clear();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteData() async {
    setState(() {
      _isLoading = true;
    });
    
    await _secureStorage.deleteAllSecureData();
    
    setState(() {
      _hasData = false;
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos los datos eliminados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.homeTitle),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.security,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Registro de Datos Cifrados',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Identificación Escolar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _privateKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Clave Privada (para cifrar/descifrar)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                      helperText: 'Esta clave será necesaria para ver tus datos',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      AppConstants.saveButtonText,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_hasData) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewDataScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(AppConstants.viewButtonText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _deleteData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text(AppConstants.deleteButtonText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    _privateKeyController.dispose();
    super.dispose();
  }
} 