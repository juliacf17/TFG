import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/common.dart';
import '../utils/changeNotifier.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<BarChartGroupData> barChartData = [];
  String selectedOption = "Mensual"; // Opción seleccionada por defecto

  @override
  void initState() {
    super.initState();
    fetchEarnings(); // Cargar datos iniciales
  }

  Future<void> fetchEarnings() async {
    if (selectedOption == "Mensual") {
      await fetchMonthlyEarnings();
    } else {
      await fetchAnnualEarnings();
    }
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
                color: monthlyEarnings[index] >= 0
                    ? Colors.green[400]
                    : Colors.red[400],
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

  Future<void> fetchAnnualEarnings() async {
    try {
      final DateTime now = DateTime.now();
      List<double> annualEarnings = List.filled(12, 0.0);

      for (int month = 1; month <= 12; month++) {
        final DateTime startOfMonth = DateTime(now.year, month, 1, 0, 0, 0);
        final DateTime endOfMonth =
            DateTime(now.year, month + 1, 0, 23, 59, 59);

        final response = await client
            .from('movimientos')
            .select()
            .gte('fecha', startOfMonth.toIso8601String())
            .lte('fecha', endOfMonth.toIso8601String());

        double earnings = 0.0;

        for (var movimiento in response) {
          if (movimiento['tipoMov'] == 'Venta') {
            earnings += movimiento['precioTotal'];
          } else if (movimiento['tipoMov'] == 'Devolución' &&
              movimiento['isPrestamo'] == false) {
            earnings -= movimiento['precioTotal'];
          }
        }

        annualEarnings[month - 1] = earnings;
      }

      setState(() {
        barChartData = List.generate(
          annualEarnings.length,
          (index) => BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                toY: annualEarnings[index],
                color: annualEarnings[index] >= 0
                    ? Colors.green[400]
                    : Colors.red[400],
                width: 20,
              ),
            ],
          ),
        );
      });
    } catch (error) {
      print('Error fetching annual earnings: $error');
    }
  }

  void onOptionChanged(String? newValue) {
    if (newValue != null && newValue != selectedOption) {
      setState(() {
        selectedOption = newValue;
      });
      fetchEarnings(); // Cargar datos cuando cambie la opción
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Pantalla de gráficos',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            foregroundColor: Colors.blue[900],
            backgroundColor: Colors.blue[200],
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: DropdownButton<String>(
                  value: selectedOption,
                  items: ["Mensual", "Anual"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: onOptionChanged,
                  underline:
                      Container(), // Para eliminar la línea debajo del dropdown
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ],
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
                              if (selectedOption == "Mensual") {
                                if (value < 1 || value > 31) return Container();
                                return Text(value.toInt().toString());
                              } else {
                                const months = [
                                  'Ene',
                                  'Feb',
                                  'Mar',
                                  'Abr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Ago',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dic'
                                ];
                                if (value < 1 || value > 12) return Container();
                                return Text(months[value.toInt() - 1]);
                              }
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
                            strokeWidth: value == 0
                                ? 2
                                : 0.5, // Línea más gruesa en el cero
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
                            String label;
                            if (selectedOption == "Mensual") {
                              label = 'Día ${group.x}';
                            } else {
                              const months = [
                                'Ene',
                                'Feb',
                                'Mar',
                                'Abr',
                                'May',
                                'Jun',
                                'Jul',
                                'Ago',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dic'
                              ];
                              label = months[group.x - 1];
                            }
                            return BarTooltipItem(
                              '$label\n',
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
      },
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Importar provider
import '../utils/common.dart';
import '../utils/changeNotifier.dart'; // Importar el RefreshNotifier

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<BarChartGroupData> barChartData = [];
  String selectedOption = "Mensual"; // Opción seleccionada por defecto

  @override
  void initState() {
    super.initState();
    fetchMonthlyEarnings(); // Cargar datos mensuales por defecto
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

  Future<void> fetchAnnualEarnings() async {
    try {
      final DateTime now = DateTime.now();
      List<double> annualEarnings = List.filled(12, 0.0);

      for (int month = 1; month <= 12; month++) {
        final DateTime startOfMonth = DateTime(now.year, month, 1, 0, 0, 0);
        final DateTime endOfMonth =
            DateTime(now.year, month + 1, 0, 23, 59, 59);

        final response = await client
            .from('movimientos')
            .select()
            .gte('fecha', startOfMonth.toIso8601String())
            .lte('fecha', endOfMonth.toIso8601String());

        double earnings = 0.0;

        for (var movimiento in response) {
          if (movimiento['tipoMov'] == 'Venta') {
            earnings += movimiento['precioTotal'];
          } else if (movimiento['tipoMov'] == 'Devolución' &&
              movimiento['isPrestamo'] == false) {
            earnings -= movimiento['precioTotal'];
          }
        }

        annualEarnings[month - 1] = earnings;
      }

      setState(() {
        barChartData = List.generate(
          annualEarnings.length,
          (index) => BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                toY: annualEarnings[index],
                color: annualEarnings[index] >= 0 ? Colors.blue : Colors.red,
                width: 20,
              ),
            ],
          ),
        );
      });
    } catch (error) {
      print('Error fetching annual earnings: $error');
    }
  }

  void onOptionChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedOption = newValue;
        if (selectedOption == "Mensual") {
          fetchMonthlyEarnings();
        } else {
          fetchAnnualEarnings();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar datos cuando se notifique un cambio
        if (selectedOption == "Mensual") {
          fetchMonthlyEarnings();
        } else {
          fetchAnnualEarnings();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Pantalla de gráficos'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: DropdownButton<String>(
                  value: selectedOption,
                  items: ["Mensual", "Anual"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: onOptionChanged,
                  underline:
                      Container(), // Para eliminar la línea debajo del dropdown
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ],
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
                              if (selectedOption == "Mensual") {
                                if (value < 1 || value > 31) return Container();
                                return Text(value.toInt().toString());
                              } else {
                                const months = [
                                  'Ene',
                                  'Feb',
                                  'Mar',
                                  'Abr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Ago',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dic'
                                ];
                                if (value < 1 || value > 12) return Container();
                                return Text(months[value.toInt() - 1]);
                              }
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
                            strokeWidth: value == 0
                                ? 2
                                : 0.5, // Línea más gruesa en el cero
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
                            String label;
                            if (selectedOption == "Mensual") {
                              label = 'Día ${group.x}';
                            } else {
                              const months = [
                                'Ene',
                                'Feb',
                                'Mar',
                                'Abr',
                                'May',
                                'Jun',
                                'Jul',
                                'Ago',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dic'
                              ];
                              label = months[group.x - 1];
                            }
                            return BarTooltipItem(
                              '$label\n',
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
      },
    );
  }
}*/

