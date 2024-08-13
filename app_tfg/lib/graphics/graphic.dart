import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/common.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<BarChartGroupData> barChartData = [];

  @override
  void initState() {
    super.initState();
    fetchMonthlyEarnings();
  }

  Future<void> fetchMonthlyEarnings() async {
    try {
      final DateTime now = DateTime.now();
      final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      List<double> monthlyEarnings = List.filled(daysInMonth, 0.0);

      for (int day = 1; day <= daysInMonth; day++) {
        final DateTime startOfDay = DateTime(now.year, now.month, day, 0, 0, 0);
        final DateTime endOfDay =
            DateTime(now.year, now.month, day, 23, 59, 59);

        final response = await client
            .from('movimientos')
            .select()
            .gte('fecha', startOfDay.toIso8601String())
            .lte('fecha', endOfDay.toIso8601String());

        double earnings = 0.0;

        for (var movimiento in response) {
          if (movimiento['tipoMov'] == 'Venta') {
            earnings += movimiento['precioTotal'];
          } else if (movimiento['tipoMov'] == 'Devolución' &&
              movimiento['isPrestamo'] == false) {
            earnings -= movimiento['precioTotal'];
          }
        }

        monthlyEarnings[day - 1] = earnings;
      }

      setState(() {
        barChartData = List.generate(
          monthlyEarnings.length,
          (index) => BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                toY: monthlyEarnings[index],
                color: monthlyEarnings[index] >= 0 ? Colors.blue : Colors.blue,
                width: 20,
              ),
            ],
          ),
        );
      });
    } catch (error) {
      print('Error fetching monthly earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de gráficos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barChartData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: value == 0
                                  ? Colors.black
                                  : Colors.grey, // Resaltar el cero
                              fontWeight: value == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value < 1 || value > 31) return Container();
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval:
                        50, // Intervalo de las líneas horizontales
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: value == 0
                            ? Colors.black
                            : Colors
                                .grey, // Color más fuerte para la línea del cero
                        strokeWidth:
                            value == 0 ? 2 : 0.5, // Línea más gruesa en el cero
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 10,
                      fitInsideHorizontally:
                          true, // Se asegura que el tooltip se ajuste al gráfico
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String day = (group.x).toString();
                        return BarTooltipItem(
                          'Día $day\n',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.toString(),
                              style: TextStyle(
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: 0,
                      color: Colors.black,
                      strokeWidth: 2,
                    )
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/common.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<BarChartGroupData> barChartData = [];

  @override
  void initState() {
    super.initState();
    fetchMonthlyEarnings();
  }

  Future<void> fetchMonthlyEarnings() async {
    try {
      final DateTime now = DateTime.now();
      final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      List<double> monthlyEarnings = List.filled(daysInMonth, 0.0);

      for (int day = 1; day <= daysInMonth; day++) {
        final DateTime startOfDay = DateTime(now.year, now.month, day, 0, 0, 0);
        final DateTime endOfDay =
            DateTime(now.year, now.month, day, 23, 59, 59);

        final response = await client
            .from('movimientos')
            .select()
            .gte('fecha', startOfDay.toIso8601String())
            .lte('fecha', endOfDay.toIso8601String());

        double earnings = 0.0;

        for (var movimiento in response) {
          if (movimiento['tipoMov'] == 'Venta') {
            earnings += movimiento['precioTotal'];
          } else if (movimiento['tipoMov'] == 'Devolución' &&
              movimiento['isPrestamo'] == false) {
            earnings -= movimiento['precioTotal'];
          }
        }

        monthlyEarnings[day - 1] = earnings;
      }

      setState(() {
        barChartData = List.generate(
          monthlyEarnings.length,
          (index) => BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                toY: monthlyEarnings[index],
                color: monthlyEarnings[index] >= 0 ? Colors.blue : Colors.red,
                width: 20,
              ),
            ],
          ),
        );
      });
    } catch (error) {
      print('Error fetching monthly earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de gráficos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barChartData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize:
                            40, // Añade espacio para evitar superposición
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value < 1 || value > 31) return Container();
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.blueGrey,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 10,
                      fitInsideHorizontally:
                          true, // Se asegura que el tooltip se ajuste al gráfico
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String day = (group.x).toString();
                        return BarTooltipItem(
                          'Día $day\n',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.toString(),
                              style: TextStyle(
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
