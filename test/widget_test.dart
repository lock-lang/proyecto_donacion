import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_donaciones/main.dart';

void main() {
  testWidgets('shows sign in and can open account registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Un gesto cambia todo'), findsOneWidget);

    await tester.tap(find.text('¿Eres nuevo? Crea tu cuenta'));
    await tester.pump();

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Ana Pérez');
    await tester.enterText(find.byType(TextFormField).at(1), 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secreto123');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Ana 👋'), findsOneWidget);
  });
}
