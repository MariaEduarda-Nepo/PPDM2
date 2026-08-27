import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------------------------
// 1) INICIALIZAÇÃO DO APP
// ---------------------------------------------------------------------------
// O main() precisa ser assíncrono porque tanto o Flutter (WidgetsFlutterBinding)
// quanto o Firebase (Firebase.initializeApp) precisam terminar de se preparar
// ANTES de qualquer tela tentar usar o Firestore. Se o app rodar antes disso,
// qualquer chamada ao Firebase vai lançar erro.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaPrincipal(),
    ),
  );
}

// ---------------------------------------------------------------------------
// 2) TELA PRINCIPAL
// ---------------------------------------------------------------------------
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // Controllers do formulário de cadastro
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController cursoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Controller do campo de pesquisa (Atividade 6)
  final TextEditingController pesquisaController = TextEditingController();
  String termoPesquisa = "";

  final CollectionReference alunosRef =
      FirebaseFirestore.instance.collection("alunos");

  @override
  void dispose() {
    nomeController.dispose();
    idadeController.dispose();
    cursoController.dispose();
    emailController.dispose();
    pesquisaController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // CREATE — cadastrar aluno (Atividade 1, 2 e 5)
  // -------------------------------------------------------------------------
  Future<void> cadastrarAluno() async {
    final String nome = nomeController.text.trim();
    final String idadeTexto = idadeController.text.trim();
    final String curso = cursoController.text.trim();
    final String email = emailController.text.trim();

    // Validação (Atividade 2): nenhum campo obrigatório pode ficar vazio.
    if (nome.isEmpty || idadeTexto.isEmpty || curso.isEmpty) {
      _mostrarMensagem("Preencha nome, idade e curso antes de cadastrar.");
      return;
    }

    // Desafio da seção 17: guardar a idade como número, não como texto.
    final int? idade = int.tryParse(idadeTexto);
    if (idade == null) {
      _mostrarMensagem("Idade inválida. Digite apenas números.");
      return;
    }

    try {
      await alunosRef.add({
        "nome": nome,
        "idade": idade,
        "curso": curso,
        "email": email, // Atividade 5
        "criadoEm": FieldValue.serverTimestamp(),
      });

      nomeController.clear();
      idadeController.clear();
      cursoController.clear();
      emailController.clear();

      _mostrarMensagem("Aluno cadastrado com sucesso!");
    } catch (e) {
      _mostrarMensagem("Erro ao cadastrar: $e");
    }
  }

  // -------------------------------------------------------------------------
  // UPDATE — editar aluno (Atividade 3)
  // -------------------------------------------------------------------------
  Future<void> editarAluno(
    String id,
    String nomeAtual,
    int idadeAtual,
    String cursoAtual,
    String emailAtual,
  ) async {
    final TextEditingController nomeEdit =
        TextEditingController(text: nomeAtual);
    final TextEditingController idadeEdit =
        TextEditingController(text: idadeAtual.toString());
    final TextEditingController cursoEdit =
        TextEditingController(text: cursoAtual);
    final TextEditingController emailEdit =
        TextEditingController(text: emailAtual);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar aluno"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeEdit,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                TextField(
                  controller: idadeEdit,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Idade"),
                ),
                TextField(
                  controller: cursoEdit,
                  decoration: const InputDecoration(labelText: "Curso"),
                ),
                TextField(
                  controller: emailEdit,
                  decoration: const InputDecoration(labelText: "E-mail"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final String novoNome = nomeEdit.text.trim();
                final String novaIdadeTexto = idadeEdit.text.trim();
                final String novoCurso = cursoEdit.text.trim();
                final String novoEmail = emailEdit.text.trim();

                if (novoNome.isEmpty ||
                    novaIdadeTexto.isEmpty ||
                    novoCurso.isEmpty) {
                  _mostrarMensagem("Preencha todos os campos obrigatórios.");
                  return;
                }

                final int? novaIdade = int.tryParse(novaIdadeTexto);
                if (novaIdade == null) {
                  _mostrarMensagem("Idade inválida.");
                  return;
                }

                // Importante: usamos .doc(id).update(), não .add() —
                // assim alteramos o documento existente em vez de criar um novo.
                await alunosRef.doc(id).update({
                  "nome": novoNome,
                  "idade": novaIdade,
                  "curso": novoCurso,
                  "email": novoEmail,
                });

                if (context.mounted) Navigator.pop(context);
                _mostrarMensagem("Aluno atualizado com sucesso!");
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // DELETE — excluir aluno (Atividade 4)
  // -------------------------------------------------------------------------
  Future<void> excluirAluno(String id, String nome) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar exclusão"),
          content: Text("Deseja realmente excluir o aluno $nome?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("EXCLUIR"),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await alunosRef.doc(id).delete();
      _mostrarMensagem("Aluno excluído.");
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 2)),
    );
  }

  // -------------------------------------------------------------------------
  // FORMULÁRIO DE CADASTRO
  // -------------------------------------------------------------------------
  Widget _buildFormulario() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: idadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Idade",
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cursoController,
              decoration: const InputDecoration(
                labelText: "Curso",
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "E-mail",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cadastrarAluno,
                icon: const Icon(Icons.add),
                label: const Text("Cadastrar Aluno"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CAMPO DE PESQUISA (Atividade 6)
  // -------------------------------------------------------------------------
  Widget _buildPesquisa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: pesquisaController,
        decoration: InputDecoration(
          hintText: "Pesquisar aluno...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (valor) {
          setState(() {
            termoPesquisa = valor.toLowerCase();
          });
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // LISTA DE ALUNOS — READ (StreamBuilder) (seções 18-20)
  // -------------------------------------------------------------------------
  Widget _buildLista() {
    return StreamBuilder<QuerySnapshot>(
      stream: alunosRef.orderBy("nome").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Erro ao carregar alunos: ${snapshot.error}"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        // Filtro de pesquisa (Atividade 6): filtra pelo nome conforme digita.
        final filtrados = documentos.where((doc) {
          final dados = doc.data() as Map<String, dynamic>;
          final nome = (dados["nome"] ?? "").toString().toLowerCase();
          return nome.contains(termoPesquisa);
        }).toList();

        if (filtrados.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text("Nenhum aluno encontrado.")),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: filtrados.length,
          itemBuilder: (context, index) {
            final doc = filtrados[index];
            final dados = doc.data() as Map<String, dynamic>;

            final String nome = dados["nome"] ?? "";
            final int idade = (dados["idade"] is int)
                ? dados["idade"]
                : int.tryParse(dados["idade"].toString()) ?? 0;
            final String curso = dados["curso"] ?? "";
            final String email = dados["email"] ?? "";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: const CircleIcon(),
                title: Text(
                  nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "$idade anos • $curso"
                  "${email.isNotEmpty ? '\n$email' : ''}",
                ),
                isThreeLine: email.isNotEmpty,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          editarAluno(doc.id, nome, idade, curso, email),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluirAluno(doc.id, nome),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // CONTADOR DE ALUNOS (Atividade 7)
  // -------------------------------------------------------------------------
  Widget _buildContador() {
    return StreamBuilder<QuerySnapshot>(
      stream: alunosRef.snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.data?.docs.length ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            "Total de alunos: $total",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Alunos"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormulario(),
            const Divider(height: 1),
            _buildPesquisa(),
            _buildContador(),
            const SizedBox(height: 4),
            _buildLista(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Ícone simples usado como avatar de cada aluno na lista.
class CircleIcon extends StatelessWidget {
  const CircleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: Colors.indigo,
      child: Icon(Icons.person, color: Colors.white),
    );
  }
}
