import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Alunos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const CadastroAlunosPage(),
    );
  }
}

class Aluno {
  final String nome;
  final int idade;
  final String curso;

  Aluno({required this.nome, required this.idade, required this.curso});
}

class CadastroAlunosPage extends StatefulWidget {
  const CadastroAlunosPage({super.key});

  @override
  State<CadastroAlunosPage> createState() => _CadastroAlunosPageState();
}

class _CadastroAlunosPageState extends State<CadastroAlunosPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();

  final List<Aluno> _alunos = [];

  void _cadastrarAluno() {
    if (_formKey.currentState!.validate()) {
      final novoAluno = Aluno(
        nome: _nomeController.text.trim(),
        idade: int.parse(_idadeController.text.trim()),
        curso: _cursoController.text.trim(),
      );

      setState(() {
        _alunos.add(novoAluno);
      });

      _nomeController.clear();
      _idadeController.clear();
      _cursoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno "${novoAluno.nome}" cadastrado com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removerAluno(int index) {
    final nomeRemovido = _alunos[index].nome;
    setState(() {
      _alunos.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aluno "$nomeRemovido" removido.')),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Alunos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Formulário de cadastro
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Novo Aluno',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome do aluno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _idadeController,
                        decoration: const InputDecoration(
                          labelText: 'Idade',
                          prefixIcon: Icon(Icons.cake),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a idade';
                          }
                          final idade = int.tryParse(value.trim());
                          if (idade == null) {
                            return 'Informe um número válido';
                          }
                          if (idade <= 0 || idade > 120) {
                            return 'Informe uma idade válida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cursoController,
                        decoration: const InputDecoration(
                          labelText: 'Curso',
                          prefixIcon: Icon(Icons.school),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o curso';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _cadastrarAluno,
                          icon: const Icon(Icons.add),
                          label: const Text('Cadastrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Alunos Cadastrados',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.indigo,
                  child: Text(
                    '${_alunos.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Lista de alunos cadastrados
            Expanded(
              child: _alunos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum aluno cadastrado ainda.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _alunos.length,
                      itemBuilder: (context, index) {
                        final aluno = _alunos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                aluno.nome.isNotEmpty
                                    ? aluno.nome[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.indigo),
                              ),
                            ),
                            title: Text(aluno.nome),
                            subtitle: Text(
                              'Idade: ${aluno.idade} • Curso: ${aluno.curso}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerAluno(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}