import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laura/models/movement_model.dart';
import 'package:laura/services/auth_service.dart';
import 'package:laura/services/movement_service.dart';

class MovementScreen extends StatelessWidget {
  MovementScreen({super.key});
  final AuthService _auth = AuthService();
  final MovementService _movementService = MovementService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Olá, ${_auth.currentUser!.displayName}')),
      body: StreamBuilder<List<MovementModel>>(
        stream: _movementService.getMovements(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar movimentações'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma movimentação encontrada'));
          } else {
            final movements = snapshot.data!;
            return ListView.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];

                return Dismissible(
                  key: Key(movement.id!),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) async {
                    // Remoção da movimentação
                    _movementService.delete(movement.id!).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Movimentação excluída!'),
                        ),
                      );
                    });
                  },
                  child: ListTile(
                    title: Text(
                      '${movement.description} - ${movement.movementType}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'R\$ ${movement.value.toStringAsFixed(2)} - ${movement.date.toDate().day}/${movement.date.toDate().month}/${movement.date.toDate().year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditMovementModal(context, movement);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMovementModal(context);
        },
        tooltip: 'Cadastrar Movimentação',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMovementModal(BuildContext context) {
    String? selectedMovementType;
    DateTime? selectedDate;
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController valueController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nova Movimentação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Selecione uma data',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMovementType,
                        onChanged: (value) {
                          setState(() {
                            selectedMovementType = value;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Entrada',
                            child: Text('Entrada'),
                          ),
                          DropdownMenuItem(
                            value: 'Saída',
                            child: Text('Saída'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Tipo de movimentação',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedMovementType == null ||
                                selectedDate == null ||
                                descriptionController.text.isEmpty ||
                                valueController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Por favor, preencha todos os campos.'),
                                ),
                              );
                              return;
                            }

                            final user = _auth.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Usuário não autenticado!'),
                                ),
                              );
                              return;
                            }

                            final userId = user.uid;
                            final description = descriptionController.text;
                            final value =
                                double.tryParse(valueController.text) ?? 0.0;

                            MovementModel newMovement = MovementModel(
                              userId: userId,
                              movementType: selectedMovementType!,
                              description: description,
                              date: Timestamp.fromDate(selectedDate!),
                              value: value,
                            );

                            _movementService.add(newMovement).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Movimentação salva com sucesso!'),
                                ),
                              );
                              Navigator.pop(context);
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Erro ao salvar movimentação: $error'),
                                ),
                              );
                            });
                          },
                          child: const Text('Criar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showEditMovementModal(BuildContext context, MovementModel movement) {
    String? selectedMovementType = movement.movementType;
    DateTime selectedDate = movement.date.toDate();
    final TextEditingController descriptionController =
        TextEditingController(text: movement.description);
    final TextEditingController valueController =
        TextEditingController(text: movement.value.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editar Movimentação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMovementType,
                        onChanged: (value) {
                          setState(() {
                            selectedMovementType = value!;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Entrada',
                            child: Text('Entrada'),
                          ),
                          DropdownMenuItem(
                            value: 'Saída',
                            child: Text('Saída'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Tipo de movimentação',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final description = descriptionController.text;
                            final value =
                                double.tryParse(valueController.text) ?? 0.0;

                            MovementModel updatedMovement = MovementModel(
                              description: description,
                              value: value,
                              movementType: selectedMovementType!,
                              date: Timestamp.fromDate(selectedDate),
                            );
                            _movementService
                                .update(movement.id!, updatedMovement)
                                .then((_) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Movimentação atualizada!'),
                                ),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao atualizar: $error'),
                                ),
                              );
                            });
                          },
                          child: const Text('Salvar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
