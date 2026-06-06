import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  // Configuração do Singleton (Instância única do banco)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

 
  Future<Database> get database async {
    if (kIsWeb) {
      return openDatabase(inMemoryDatabasePath);
    }

    if (_database != null) return _database!;
    _database = await _initDB('agenda.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Cria a tabela de tarefas quando o app abre pela primeira vez
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        horario TEXT NOT NULL
      )
    ''');
  }

  // Função para INSERIR uma tarefa no banco
  Future<int> inserirTarefa(String titulo, String horario) async {
    final db = await instance.database;
    return await db.insert('tarefas', {'titulo': titulo, 'horario': horario});
  }

  // Função para BUSCAR todas as tarefas do banco
  Future<List<Map<String, dynamic>>> buscarTarefas() async {
    final db = await instance.database;
    return await db.query('tarefas', orderBy: 'horario ASC');
  }

  // Função para DELETAR uma tarefa do banco
  Future<int> deletarTarefa(int id) async {
    final db = await instance.database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
