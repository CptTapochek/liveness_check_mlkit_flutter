import 'package:flutter/material.dart';
import 'package:real_time_chart/real_time_chart.dart';

class RealTimeGraphCustom extends StatefulWidget {
  const RealTimeGraphCustom({
    Key? key,
    required this.data
  }) : super(key: key);
  final double data;

  @override
  State<RealTimeGraphCustom> createState() => _RealTimeGraphCustomState();
}

class _RealTimeGraphCustomState extends State<RealTimeGraphCustom> {
  Stream<double> positiveDataStream() {
    return Stream.periodic(const Duration(milliseconds: 50), (_) {
      return double.parse((widget.data * 100).toStringAsFixed(1));
    }).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return RealTimeGraph(
      stream: positiveDataStream(),
      // supportNegativeValuesDisplay: true,
      graphColor: Colors.black,
    );
  }
}
