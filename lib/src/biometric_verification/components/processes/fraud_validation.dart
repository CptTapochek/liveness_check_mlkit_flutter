import 'dart:math';


class FraudValidation {
  void getDeviation({required List<double> dataSet, required Function callBack}) {
    double mean = dataSet.reduce((value, element) => value + element) / dataSet.length;
    double sumOf = 0.0;

    for(double data in dataSet) {
      sumOf += pow(data - mean, 2);
    }
    double deviation = sqrt(sumOf / (dataSet.length - 1));
    callBack(deviation);
  }
}