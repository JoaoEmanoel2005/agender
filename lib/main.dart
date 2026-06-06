import 'package:flutter/material.dart';
import 'database_helper.dart'; // Importa o arquivo que criamos no passo 1



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Agenda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista que vai armazenar as tarefas vindas do SQLite
  List<Map<String, dynamic>> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizarTarefas(); // Busca as tarefas assim que o app abre
  }

  // Função para buscar os dados do SQLite e atualizar a tela
  Future<void> _atualizarTarefas() async {
    setState(() => _carregando = true);
    final dados = await DatabaseHelper.instance.buscarTarefas();
    setState(() {
      _tarefas = dados;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('🗓️ Minha Agenda Real'),
        centerTitle: true,
      ),

      // Se estiver carregando mostra um círculo de progresso, senão mostra a lista
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma tarefa salva! 🎉',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefas[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.deepPurple),
                    title: Text(
                      tarefa['titulo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('⏰ Horário: ${tarefa['horario']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        // Deleta do SQLite usando o ID único da tarefa
                        await DatabaseHelper.instance.deletarTarefa(
                          tarefa['id'],
                        );
                        _atualizarTarefas(); // Atualiza a lista na tela
                      },
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioAdicionar(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _abrirFormularioAdicionar(BuildContext context) {
    String novoTitulo = '';
    String novoHorario = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'O que precisa fazer?',
                ),
                onChanged: (valor) => novoTitulo = valor,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Horário (ex: 15:30)',
                ),
                onChanged: (valor) => novoHorario = valor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (novoTitulo.isNotEmpty && novoHorario.isNotEmpty) {
                  // Salva a tarefa de verdade no SQLite
                  await DatabaseHelper.instance.inserirTarefa(
                    novoTitulo,
                    novoHorario,
                  );
                  _atualizarTarefas(); // Recarrega a tela com a nova tarefa
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
