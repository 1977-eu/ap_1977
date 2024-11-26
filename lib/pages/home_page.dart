import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/dashboard_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Motoristas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/cadastro-motorista');
            },
            tooltip: 'Novo Motorista',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: const DashboardWidget(),
    );
  }
}
