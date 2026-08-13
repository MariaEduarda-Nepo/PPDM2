// Teste básico da tela de Cadastro de Alunos.
//
// Se o nome do seu pacote no pubspec.yaml (campo "name:") for diferente de
// "cadastro_alunos", ajuste o import abaixo para o nome correto, por exemplo:
// import 'package:nome_do_seu_projeto/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cadastro_alunos/main.dart';

void main() {
  testWidgets('Tela de cadastro exibe campos e botão', (WidgetTester tester) async {
    // Constrói o app e renderiza um frame.
    await tester.pumpWidget(const MyApp());

    // Verifica se o título do formulário aparece.
    expect(find.text('Novo Aluno'), findsOneWidget);

    // Verifica se os campos existem.
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Idade'), findsOneWidget);
    expect(find.text('Curso'), findsOneWidget);

    // Verifica se o botão de cadastrar existe.
    expect(find.text('Cadastrar'), findsOneWidget);

    // Verifica se a lista começa vazia.
    expect(find.text('Nenhum aluno cadastrado ainda.'), findsOneWidget);
  });

  testWidgets('Cadastra um aluno e mostra na lista', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Preenche os campos do formulário.
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Maria Silva');
    await tester.enterText(find.widgetWithText(TextFormField, 'Idade'), '20');
    await tester.enterText(find.widgetWithText(TextFormField, 'Curso'), 'Engenharia');

    // Toca no botão Cadastrar.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump(); // Reconstrói a tela após o setState.

    // Verifica se o aluno cadastrado aparece na lista.
    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.textContaining('Idade: 20'), findsOneWidget);
    expect(find.textContaining('Engenharia'), findsOneWidget);
  });
}