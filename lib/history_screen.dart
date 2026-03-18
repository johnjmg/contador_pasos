import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models/step_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<StepRecord> _records = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_email') ?? '';
    
    final records = await _dbHelper.getRecords(userId);
    setState(() => _records = records);
  }

  Future<void> _deleteRecord(int id) async {
    await _dbHelper.deleteRecord(id);
    _loadRecords();
  }

  Future<void> _clearAllRecords() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar todo el historial?'),
        content: Text('Esta acción no se puede deshacer'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('user_email') ?? '';
              await _dbHelper.clearAllRecords(userId);
              _loadRecords();
              Navigator.pop(context);
            },
            child: Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Pasos'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _clearAllRecords,
            tooltip: 'Limpiar historial',
          ),
        ],
      ),
      body: _records.isEmpty
          ? Center(child: Text('No hay registros guardados'))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.directions_walk, color: Colors.blue),
                    title: Text('${record.steps} pasos'),
                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(record.dateTime)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecord(record.id!),
                    ),
                  ),
                );
              },
            ),
    );
  }
}