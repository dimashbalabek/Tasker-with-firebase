import 'package:firebase_first_project/data/source/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget {
  final List<double> weeklySummary;

  MyBarGraph({super.key, required this.weeklySummary});

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
      sunAmount: weeklySummary[0],
      monAmount: weeklySummary[1],
      tueAmount: weeklySummary[2],
      wedAmount: weeklySummary[3],
      thurAmount: weeklySummary[4],
      friAmount: weeklySummary[5],
      satAmount: weeklySummary[6],
    );
    myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles( 
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
              reservedSize: 32,
            ),
          ),
        ),
        maxY: 100,
        minY: 0,
        barGroups: myBarData.barData.map(
          (data) => BarChartGroupData(
            x: data.x, 
            barRods: [
              BarChartRodData(
                toY: data.y,
                color: Colors.green,
                width: 14,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 100, 
                  color: const Color.fromARGB(100, 221, 221, 221), 
                ),
              ),
            ],  
          ),
        ).toList(), 
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  Widget text;
  switch (value.toInt()) {
    case 1: text = const Text("Mn", style: style); break; 
    case 2: text = const Text("Tu", style: style); break;
    case 3: text = const Text("Wd", style: style); break;
    case 4: text = const Text("Th", style: style); break;
    case 5: text = const Text("Fr", style: style); break;
    case 6: text = const Text("St", style: style); break; 
    case 7: text = const Text("Sn", style: style); break; 

    default: text = const Text("", style: style); break;
  }

  return SideTitleWidget(
    child: text,
    meta: meta,
  );
}
