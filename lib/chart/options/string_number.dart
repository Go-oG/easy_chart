class SNumber {
  final double number;
  final bool percent;

  const SNumber(this.number, this.percent);

  const SNumber.percent(this.number) : percent = true;

  const SNumber.number(this.number) : percent = false;
}
