import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/country_service.dart';

class EditarMotoristaPage extends StatefulWidget {
  final String motoristaId;
  final Map<String, dynamic> motorista;

  const EditarMotoristaPage({
    super.key,
    required this.motoristaId,
    required this.motorista,
  });

  @override
  State<EditarMotoristaPage> createState() => _EditarMotoristaPageState();
}

class _EditarMotoristaPageState extends State<EditarMotoristaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _nif;
  String? _nome;
  String? _apelido;
  String? _empresa;
  String? _nacionalidade;
  String? _cc;
  String? _iban;
  String? _morada;
  DateTime? _dataNascimento;
  bool? _ativo;
  final _nifController = TextEditingController();
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _ccController = TextEditingController();
  final _empresaController = TextEditingController();
  final _aniversarioController = TextEditingController();
  final _ibanController = TextEditingController();
  final _moradaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosMotorista();
  }

  Future<void> _carregarDadosMotorista() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final motorista = widget.motorista;
      _nif = motorista['nif'];
      _nome = motorista['nome'];
      _apelido = motorista['sobrenome'];
      _empresa = motorista['empresa'];
      _nacionalidade = CountryService.convertLegacyCode(motorista['nacionalidade']);
      _cc = motorista['cc'];
      _iban = motorista['iban'];
      _morada = motorista['morada'];
      _ativo = motorista['ativo'] ?? true;
      
      // Tratamento da data de aniversário
      if (motorista['aniversario'] != null) {
        try {
          _dataNascimento = DateTime.parse(motorista['aniversario']);
        } catch (e) {
          // Se falhar ao fazer parse da data ISO, tenta outros formatos
          final parts = motorista['aniversario'].split('/');
          if (parts.length == 3) {
            _dataNascimento = DateTime(
              int.parse(parts[2]), // ano
              int.parse(parts[1]), // mês
              int.parse(parts[0]), // dia
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar dados do motorista'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _nifController.text = _nif ?? '';
        _nomeController.text = _nome ?? '';
        _apelidoController.text = _apelido ?? '';
        _ccController.text = _cc ?? '';
        _empresaController.text = _empresa ?? '';
        _aniversarioController.text = _dataNascimento != null 
            ? '${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}'
            : '';
        _ibanController.text = _iban ?? '';
        _moradaController.text = _morada ?? '';
      });
    }
  }

  Future<void> _atualizarMotorista() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('motoristas')
            .doc(widget.motoristaId)
            .update({
          'nif': _nifController.text,
          'nome': _nomeController.text,
          'sobrenome': _apelidoController.text,
          'cc': _ccController.text,
          'empresa': _empresaController.text,
          'ativo': _ativo,
          'nacionalidade': _nacionalidade,
          'aniversario': _dataNascimento?.toIso8601String(),
          'iban': _ibanController.text,
          'morada': _moradaController.text,
        });

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Motorista atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar motorista'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nifController.dispose();
    _nomeController.dispose();
    _apelidoController.dispose();
    _ccController.dispose();
    _empresaController.dispose();
    _aniversarioController.dispose();
    _ibanController.dispose();
    _moradaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Motorista'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nifController,
                      decoration: const InputDecoration(
                        labelText: 'NIF',
                        icon: Icon(Icons.credit_card),
                      ),
                      enabled: false, // NIF não pode ser editado
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        icon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apelidoController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        icon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o sobrenome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ccController,
                      decoration: const InputDecoration(
                        labelText: 'CC',
                        icon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o CC';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _empresaController,
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        icon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a empresa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Motorista Ativo'),
                      value: _ativo ?? true,
                      onChanged: (bool value) {
                        setState(() {
                          _ativo = value;
                        });
                      },
                      secondary: const Icon(Icons.toggle_on),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _nacionalidade,
                      decoration: const InputDecoration(
                        labelText: 'Nacionalidade',
                        icon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: CountryService.countries.map((country) {
                        final flag = CountryService.getFlagEmoji(country);
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: Text(
                                  flag ?? '',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              Text(country),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _nacionalidade = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione a nacionalidade';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _aniversarioController,
                      decoration: const InputDecoration(
                        labelText: 'Aniversário',
                        icon: Icon(Icons.cake),
                        hintText: 'DD/MM/AAAA',
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          try {
                            final parts = value.split('/');
                            if (parts.length == 3) {
                              _dataNascimento = DateTime(
                                int.parse(parts[2]), // ano
                                int.parse(parts[1]), // mês
                                int.parse(parts[0]), // dia
                              );
                            }
                          } catch (e) {
                            // Ignora erros de parse
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o aniversário';
                        }
                        // Validar formato da data
                        final parts = value.split('/');
                        if (parts.length != 3) {
                          return 'Use o formato DD/MM/AAAA';
                        }
                        try {
                          final day = int.parse(parts[0]);
                          final month = int.parse(parts[1]);
                          final year = int.parse(parts[2]);
                          if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
                            return 'Data inválida';
                          }
                        } catch (e) {
                          return 'Data inválida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ibanController,
                      decoration: const InputDecoration(
                        labelText: 'IBAN',
                        icon: Icon(Icons.account_balance),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o IBAN';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _moradaController,
                      decoration: const InputDecoration(
                        labelText: 'Morada',
                        icon: Icon(Icons.home),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a morada';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _atualizarMotorista,
                      icon: const Icon(Icons.save),
                      label: const Text('Atualizar Motorista'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
