import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/country_service.dart';

class CadastroMotoristaPage extends StatefulWidget {
  const CadastroMotoristaPage({super.key});

  @override
  State<CadastroMotoristaPage> createState() => _CadastroMotoristaPageState();
}

class _CadastroMotoristaPageState extends State<CadastroMotoristaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nifController = TextEditingController();
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _ccController = TextEditingController();
  final _empresaController = TextEditingController();
  String? _nacionalidade;
  final _aniversarioController = TextEditingController();
  final _ibanController = TextEditingController();
  final _moradaController = TextEditingController();
  bool _ativo = true;
  bool _verificandoNif = false;
  String? _nifError;

  Future<bool> _verificarNifExistente(String nif) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('motoristas')
        .where('nif', isEqualTo: nif)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  void _verificarNifAoDigitar() async {
    final nif = _nifController.text;
    if (nif.length == 9) { // Verifica apenas quando tiver exatamente 9 dígitos
      setState(() {
        _verificandoNif = true;
        _nifError = null;
      });

      final existe = await _verificarNifExistente(nif);
      
      if (mounted) {
        setState(() {
          _verificandoNif = false;
          _nifError = existe ? 'Este NIF já está cadastrado' : null;
        });
      }
    } else {
      setState(() {
        _nifError = null; // Limpa o erro se o NIF não tiver 9 dígitos
      });
    }
  }

  Future<void> _salvarMotorista() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_nifError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIF já cadastrado no sistema!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final nifExistente = await _verificarNifExistente(_nifController.text);
        if (nifExistente) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIF já cadastrado no sistema!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('motoristas').add({
          'nif': _nifController.text,
          'nome': _nomeController.text,
          'sobrenome': _sobrenomeController.text,
          'cc': _ccController.text,
          'empresa': _empresaController.text,
          'ativo': _ativo,
          'nacionalidade': _nacionalidade,
          'aniversario': _aniversarioController.text,
          'iban': _ibanController.text,
          'morada': _moradaController.text,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Motorista cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpar formulário
        _formKey.currentState!.reset();
        _nifController.clear();
        _nomeController.clear();
        _sobrenomeController.clear();
        _ccController.clear();
        _empresaController.clear();
        _nacionalidade = null;
        _aniversarioController.clear();
        _ibanController.clear();
        _moradaController.clear();
        setState(() {
          _ativo = true;
          _nifError = null; // Limpar o erro do NIF
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar motorista: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nifController.addListener(_verificarNifAoDigitar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Motorista'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nifController,
                decoration: InputDecoration(
                  labelText: 'NIF',
                  icon: const Icon(Icons.credit_card),
                  errorText: _nifError,
                  suffixIcon: _verificandoNif 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : _nifError == null && _nifController.text.length >= 9
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o NIF';
                  }
                  if (value.length != 9) {
                    return 'O NIF deve ter 9 dígitos';
                  }
                  if (_nifError != null) {
                    return _nifError;
                  }
                  return null;
                },
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
                controller: _sobrenomeController,
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
                  icon: Icon(Icons.credit_card),
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
                title: const Text('Ativo'),
                value: _ativo,
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o aniversário';
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
                onPressed: _salvarMotorista,
                icon: const Icon(Icons.save),
                label: const Text('Cadastrar Motorista'),
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

  @override
  void dispose() {
    _nifController.removeListener(_verificarNifAoDigitar);
    _nifController.dispose();
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _ccController.dispose();
    _empresaController.dispose();
    _aniversarioController.dispose();
    _ibanController.dispose();
    _moradaController.dispose();
    super.dispose();
  }
}
