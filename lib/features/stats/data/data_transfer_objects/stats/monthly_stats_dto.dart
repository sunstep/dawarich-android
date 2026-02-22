class MonthlyStatsDTO {
  int january;
  int february;
  int march;
  int april;
  int may;
  int june;
  int july;
  int august;
  int september;
  int october;
  int november;
  int december;

  MonthlyStatsDTO({
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
  });

  factory MonthlyStatsDTO.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsDTO(
      january: json["january"] ?? 0,
      february: json["february"] ?? 0,
      march: json["march"] ?? 0,
      april: json["april"] ?? 0,
      may: json["may"] ?? 0,
      june: json["june"] ?? 0,
      july: json["july"] ?? 0,
      august: json["august"] ?? 0,
      september: json["september"] ?? 0,
      october: json["october"] ?? 0,
      november: json["november"] ?? 0,
      december: json["december"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "january": january,
      "february": february,
      "march": march,
      "april": april,
      "may": may,
      "june": june,
      "july": july,
      "august": august,
      "september": september,
      "october": october,
      "november": november,
      "december": december,
    };
  }
}
