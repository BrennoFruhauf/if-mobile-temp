import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:laura/services/auth_service.dart';
import 'package:laura/services/movement_service.dart';

import '../models/movement_model.dart';

class ChartScreen extends StatelessWidget {
  final _movementService = MovementService();
  final _authService = AuthService();

  ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Gráficos de Movimentações")),
      body: StreamBuilder<List<MovementModel>>(
        stream: _movementService.getMovements(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao carregar os dados: ${snapshot.error}"),
            );
          }

          final movements = snapshot.data;

          if (movements == null || movements.isEmpty) {
            return const Center(
                child: Text("Nenhuma movimentação encontrada."));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildLineChart(movements),
              const SizedBox(height: 24),
              _buildBarChart(movements),
              const SizedBox(height: 24),
              _buildPieChart(movements),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLineChart(List<MovementModel> movements) {
    List<FlSpot> entrySpots = [];
    List<FlSpot> exitSpots = [];

    for (var movement in movements) {
      final movementDate = movement.date.toDate();
      int dayOfYear =
          movementDate.difference(DateTime(movementDate.year, 1, 1)).inDays + 1;
      double value = movement.value;

      if (movement.movementType == 'Entrada') {
        entrySpots.add(FlSpot(dayOfYear.toDouble(), value));
      } else {
        exitSpots.add(FlSpot(dayOfYear.toDouble(), value));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Movimentações por Dia",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) =>
                        Text(value.toInt().toString()),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  isCurved: false,
                  spots: entrySpots,
                  barWidth: 4,
                  color: Colors.blue,
                ),
                LineChartBarData(
                  isCurved: false,
                  spots: exitSpots,
                  barWidth: 4,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<MovementModel> movements) {
    double totalEntradas = 0;
    double totalSaidas = 0;

    for (var movement in movements) {
      if (movement.movementType == 'Entrada') {
        totalEntradas += movement.value;
      } else {
        totalSaidas += movement.value;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Total de Entradas vs. Saídas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) => value == 0
                        ? const Text('Entradas')
                        : const Text('Saídas'),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(toY: totalEntradas, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: totalSaidas, color: Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Gráfico de pizza
  Widget _buildPieChart(List<MovementModel> movements) {
    int totalEntradas =
        movements.where((m) => m.movementType == 'Entrada').length;
    int totalSaidas = movements.where((m) => m.movementType == 'Saída').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Proporção de Entradas e Saídas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: totalEntradas.toDouble(),
                  color: Colors.blue,
                  title: 'Entradas\n ${totalEntradas}',
                  radius: 50,
                ),
                PieChartSectionData(
                  value: totalSaidas.toDouble(),
                  color: Colors.purple,
                  title: 'Saídas\n ${totalSaidas}',
                  radius: 50,
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
      ],
    );
  }
}
