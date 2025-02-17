import 'package:firebase_first_project/presentation/widgets/individual_bar.dart';

class BarData {
  final double sunAmount;
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thurAmount;
  final double friAmount;
  final double satAmount;

  BarData({
    required this.sunAmount,
    required this.monAmount,
    required this.tueAmount,
    required this.wedAmount,
    required this.thurAmount,
    required this.friAmount,
    required this.satAmount
  });

  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = [
      // sun
      IndividualBar(x: 1, y: sunAmount),
      // mon
      IndividualBar(x: 2, y: monAmount),
      // tue
      IndividualBar(x: 3, y: tueAmount),
      // wed
      IndividualBar(x: 4, y: wedAmount),
      // thur
      IndividualBar(x: 5, y: thurAmount),
      // fri
      IndividualBar(x: 6, y: friAmount),
      // sat
      IndividualBar(x: 7, y: satAmount)
    ];
  }
}