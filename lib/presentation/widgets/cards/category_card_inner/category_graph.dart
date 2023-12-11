import 'dart:math';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class CategoryGraph extends StatelessWidget {
  final List<double> dataPoints;
  final List<Color> gradientColors;
  final Color lineColor;

  // final bool? enableTouch;

  const CategoryGraph({
    super.key,
    required this.dataPoints,
    required this.gradientColors,
    required this.lineColor,
    // this.enableTouch = true,
  });

  List<FlSpot> _generateChartData(List<double> dataPoints) {
    return List.generate(dataPoints.length,
        (index) => FlSpot(index.toDouble(), dataPoints[index]));
  }

  @override
  Widget build(BuildContext context) {
    double maxVal = dataPoints.reduce(max);
    double minVal = dataPoints.reduce(min);
    if (minVal == maxVal) {
      minVal = 0;
    }
    double range = maxVal - minVal;
    double padding = range * 0.10;

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: false,
                ),
                titlesData: const FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: dataPoints.length.toDouble() - 1,
                minY: minVal - padding,
                maxY: maxVal + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartData(dataPoints),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 1,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradientColors
                            .map((color) => color.withOpacity(0.3))
                            .toList(),
                      ),
                    ),
                  ),
                ],
                lineTouchData: const LineTouchData(
                  enabled: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
