import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_motorista_page.dart';
import '../services/country_service.dart';

class ConsultaMotoristaPage extends StatefulWidget {
  const ConsultaMotoristaPage({super.key});

  @override
  State<ConsultaMotoristaPage> createState() => _ConsultaMotoristaPageState();
}

class _ConsultaMotoristaPageState extends State<ConsultaMotoristaPage> {
  final _nifController = TextEditingController();
  final _nomeController = TextEditingController();
  final _ccController = TextEditingController();
  final _empresaController = TextEditingController();
  final _nacionalidadeController = TextEditingController();
  bool _isLoading = false;
  List<DocumentSnapshot> _motoristas = [];

  Future<void> _consultarMotoristas() async {
    setState(() {
      _isLoading = true;
      _motoristas = [];
    });

    try {
      Query query = FirebaseFirestore.instance.collection('motoristas');

      // Aplicar um filtro por vez para evitar necessidade de índices compostos
      if (_nifController.text.isNotEmpty) {
        query = query.where('nif', isEqualTo: _nifController.text);
      } else if (_nacionalidadeController.text.isNotEmpty) {
        String paisBusca = _nacionalidadeController.text;
        // Procura o país ignorando maiúsculas/minúsculas
        for (String pais in CountryService.countries) {
          if (pais.toLowerCase() == paisBusca.toLowerCase()) {
            paisBusca = pais; // Usa o nome com a capitalização correta
            break;
          }
        }
        query = query.where('nacionalidade', isEqualTo: paisBusca);
      } else if (_empresaController.text.isNotEmpty) {
        query = query.where('empresa', isEqualTo: _empresaController.text);
      } else if (_ccController.text.isNotEmpty) {
        query = query.where('cc', isEqualTo: _ccController.text);
      }

      final resultado = await query.get();
      
      if (mounted) {
        setState(() {
          // Filtrar os resultados localmente
          _motoristas = resultado.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            bool matches = true;

            // Aplicar filtros adicionais localmente
            if (_nomeController.text.isNotEmpty) {
              final nome = data['nome'] as String;
              matches = matches && nome.toLowerCase().contains(_nomeController.text.toLowerCase());
            }
            
            if (_nacionalidadeController.text.isNotEmpty && _nifController.text.isEmpty) {
              matches = matches && data['nacionalidade'] == _nacionalidadeController.text;
            }
            
            if (_empresaController.text.isNotEmpty && _nifController.text.isEmpty && _nacionalidadeController.text.isEmpty) {
              matches = matches && data['empresa'] == _empresaController.text;
            }
            
            if (_ccController.text.isNotEmpty && _nifController.text.isEmpty && _nacionalidadeController.text.isEmpty && _empresaController.text.isEmpty) {
              matches = matches && data['cc'] == _ccController.text;
            }

            return matches;
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao consultar motoristas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildResultadoList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_motoristas.isEmpty) {
      return const Center(
        child: Text('Nenhum motorista encontrado'),
      );
    }

    return ListView.builder(
      itemCount: _motoristas.length,
      itemBuilder: (context, index) {
        final motorista = _motoristas[index].data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            title: Text(
              '${motorista['nome']} ${motorista['sobrenome']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NIF: ${motorista['nif']}'),
                Text('CC: ${motorista['cc']}'),
                Text('Empresa: ${motorista['empresa']}'),
                Text('Nacionalidade: ${motorista['nacionalidade']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  motorista['ativo'] == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: motorista['ativo'] == true
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarMotoristaPage(
                          motoristaId: _motoristas[index].id,
                          motorista: motorista,
                        ),
                      ),
                    );
                    
                    if (updated == true) {
                      // Recarregar a lista após a edição
                      _consultarMotoristas();
                    }
                  },
                ),
              ],
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
        title: const Text('Consulta de Motoristas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nifController,
                      decoration: const InputDecoration(
                        labelText: 'NIF',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ccController,
                      decoration: const InputDecoration(
                        labelText: 'CC',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _empresaController,
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nacionalidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Nacionalidade',
                        prefixIcon: Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _consultarMotoristas,
                            icon: const Icon(Icons.search),
                            label: const Text('Consultar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _nifController.clear();
                              _nomeController.clear();
                              _ccController.clear();
                              _empresaController.clear();
                              _nacionalidadeController.clear();
                              _motoristas = [];
                            });
                          },
                          icon: const Icon(Icons.clear),
                          tooltip: 'Limpar filtros',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildResultadoList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nifController.dispose();
    _nomeController.dispose();
    _ccController.dispose();
    _empresaController.dispose();
    _nacionalidadeController.dispose();
    super.dispose();
  }
}
