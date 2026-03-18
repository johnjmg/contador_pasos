import 'package:flutter/material.dart';
/* import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart'; */
// Importar las pantallas
import 'splash_screen.dart';
import 'auth_screen.dart';
import 'history_screen.dart';
import 'developer_info_screen.dart';
// Importar DB, modelos y SharedPreferences
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Para SharedPreferences
import 'database_helper.dart'; // ✅ Para DatabaseHelper
import 'models/step_record.dart'; // ✅ Para StepRecord
// Importar url_launcher
//import 'package:url_launcher/url_launcher.dart'; // ✅ Para abrir enlaces
// Importar Health Connect y permisos
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async'; // Para StreamSubscription

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => AuthScreen(),
        '/home': (context) => MyHomeScreen(), // ✅ Inicio
        '/history': (context) => HistoryScreen(),
        '/developer': (context) => DeveloperInfoScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomeScreen extends StatefulWidget {  // ✅ MyHomeScreen
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();  // ✅ _MyHomeScreenState
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _steps = 0;
  String _status = 'Cargando...';
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  // ✅ MÉTODO SIMPLIFICADO con sensors_plus
  Future<void> initSensors() async {
    try {
      setState(() {
        _status = 'Iniciando sensor...';
      });

      // ✅ Usar solo accelerometer de sensors_plus
      _sensorSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          // Lógica simple para detectar pasos
          if ((event.x.abs() > 10 || event.y.abs() > 10) && _status != 'Paso detectado') {
            setState(() {
              _steps++;
              _status = 'Paso detectado';
            });
            
            // Resetear el estado después de un tiempo
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _status = 'Monitoreando...';
                });
              }
            });
          }
        },
        onError: (error) {
          setState(() {
            _status = 'Error del sensor: $error';
          });
        },
        cancelOnError: true,
      );
      
      setState(() {
        _status = 'Sensor activado. ¡Camina!';
      });
      
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  // ✅ Método para cerrar sesión (MANTIENE tu código)
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initSensors();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  // ✅ MANTIENE tu build method COMPLETO (solo cambia initHealth por initSensors)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contador de Pasos'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
            tooltip: 'Ver historial de pasos',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/developer'),
            tooltip: 'Desarrollador',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pasos:', style: TextStyle(fontSize: 24)),
            Text('$_steps', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Estado: $_status'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _steps = 0; // Resetear contador
                  _status = 'Contador reiniciado';
                });
              },
              child: Text('Reiniciar'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveRecord,
        child: Icon(Icons.save),
        tooltip: 'Guardar registro',
      ),
    );
  }

  // ✅ MANTIENE tu _saveRecord COMPLETO (sin cambios)
  Future<void> _saveRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_email') ?? '';

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario no identificado. Por favor, inicie sesión.')),
        );
        return;
      }
      
      final newRecord = StepRecord(
        dateTime: DateTime.now(),
        steps: _steps,
        userId: userId,
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.insertRecord(newRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro guardado: $_steps pasos')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }
}// Fin _HomeScreenState