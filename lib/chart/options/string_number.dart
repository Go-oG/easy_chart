class SNumber {
  final double number;
  final bool percent;

  const SNumber(this.number, this.percent);

  const SNumber.percent(this.number) : percent = true;

  const SNumber.number(this.number) : percent = false;

  double percentRatio() {
    return number / 100.0;
  }

  double convert(double number) {
    if (percent) {
      return number * percentRatio();
    }
    return number;
  }
}
