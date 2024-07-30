/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/common.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String _selectedPeriod = 'Mensual';
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    super.initState();
    fetchEarningsData();
  }

  Future<void> fetchEarningsData() async {
    try {
      final now = DateTime.now();
      final startDate = _selectedPeriod == 'Mensual'
          ? DateTime(now.year, now.month, 1)
          : DateTime(now.year, 1, 1);
      final endDate = _selectedPeriod == 'Mensual'
          ? DateTime(now.year, now.month + 1, 0, 23, 59, 59)
          : DateTime(now.year, 12, 31, 23, 59, 59);

      final response = await client
          .from('movimientos')
          .select()
          .gte('fecha', startDate.toIso8601String())
          .lte('fecha', endDate.toIso8601String());

      Map<String, double> dailyEarnings = {};

      for (var movimiento in response) {
        final date = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(movimiento['fecha']));
        if (movimiento['tipoMov'] == 'Venta') {
          dailyEarnings[date] =
              (dailyEarnings[date] ?? 0) + movimiento['precioTotal'];
        } else if (movimiento['tipoMov'] == 'Devolución' &&
            movimiento['isPrestamo'] == false) {
          dailyEarnings[date] =
              (dailyEarnings[date] ?? 0) - movimiento['precioTotal'];
        }
      }

      setState(() {
        barGroups = dailyEarnings.entries.map((entry) {
          final date = DateFormat('d').format(DateTime.parse(entry.key));
          return BarChartGroupData(
            x: int.parse(date),
            barRods: [
              BarChartRodData(y: entry.value, colors: [Colors.blue])
            ],
          );
        }).toList();
      });
    } catch (error) {
      print('Error fetching earnings data: $error');
    }
  }

  void _onPeriodChanged(String? value) {
    setState(() {
      _selectedPeriod = value!;
      fetchEarningsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de gráficos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              items: <String>['Mensual', 'Anual'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _onPeriodChanged,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (double value) => value.toInt().toString(),
                    ),
                    leftTitles: SideTitles(showTitles: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
