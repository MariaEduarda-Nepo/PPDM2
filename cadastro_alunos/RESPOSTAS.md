# Respostas — Perguntas teóricas (seção 38)

**1. Qual é a função do Firebase em uma aplicação Flutter?**
O Firebase funciona como o "backend pronto" do aplicativo: ele guarda os dados na nuvem (Firestore), autentica usuários, hospeda arquivos, entre outros serviços — sem que o desenvolvedor precise criar e manter um servidor próprio. No app de Cadastro de Alunos, ele é responsável por armazenar e sincronizar a lista de alunos.

**2. Para que serve o pacote `firebase_core`?**
Ele é o pacote base que conecta o Flutter ao projeto Firebase. É ele quem executa `Firebase.initializeApp()`, lendo as configurações do `google-services.json` e preparando a conexão para que outros pacotes (como o `cloud_firestore`) possam ser usados.

**3. Para que serve o `cloud_firestore`?**
É o pacote que permite ler e escrever dados no Cloud Firestore — o banco de dados NoSQL do Firebase. É com ele que o app cadastra, lista, edita e exclui os alunos.

**4. O que é uma coleção no Firestore?**
Uma coleção é como uma "pasta" que agrupa documentos do mesmo tipo. No projeto, a coleção `alunos` reúne todos os documentos que representam um aluno cadastrado.

**5. O que é um documento?**
Um documento é um registro individual dentro de uma coleção, formado por pares de campo/valor (como uma linha em uma tabela). Cada aluno cadastrado vira um documento dentro da coleção `alunos`, contendo os campos `nome`, `idade`, `curso` e `email`.

**6. Qual método é utilizado para inserir dados?**
O método `.add()`, chamado sobre a referência da coleção:
`FirebaseFirestore.instance.collection("alunos").add({...})`.
Ele cria um novo documento com um ID gerado automaticamente.

**7. Qual método é utilizado para atualizar dados?**
O método `.update()`, chamado sobre a referência de um documento específico:
`FirebaseFirestore.instance.collection("alunos").doc(id).update({...})`.
Ele altera os campos informados sem recriar o documento.

**8. Qual método é utilizado para excluir dados?**
O método `.delete()`, chamado sobre a referência de um documento específico:
`FirebaseFirestore.instance.collection("alunos").doc(id).delete()`.

**9. Qual é a diferença entre `setState()` e o Firestore?**
`setState()` atualiza apenas o estado local do widget, refletindo a mudança somente na tela do próprio dispositivo, e essa informação se perde ao fechar o app. Já o Firestore guarda os dados de forma persistente na nuvem — as informações continuam existindo mesmo depois de fechar o aplicativo, e podem ser acessadas de qualquer dispositivo. No app, o `StreamBuilder` combina os dois: ele "escuta" o Firestore e aciona automaticamente uma atualização de tela (equivalente a um `setState()`) sempre que os dados mudam.

**10. Por que os dados continuam disponíveis depois de fechar o aplicativo?**
Porque os dados não ficam armazenados apenas na memória do app (que é apagada ao fechar), e sim no banco de dados na nuvem do Firestore. Ao reabrir o app, o `StreamBuilder` consulta novamente a coleção `alunos` no Firebase e recupera tudo o que já havia sido salvo.
