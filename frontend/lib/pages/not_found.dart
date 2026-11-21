import 'package:material_ui/material_ui.dart';
import 'package:nocsis/routes/router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("404: Page not found"),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("Home"),
              onPressed: () => const TopPageRoute().go(context),
            ),
          ],
        ),
      ),
    );
  }
}
