class SinhalaMapper {

  static const Map<String, String> gestureToSinhala = {

    // base model gestures
    "ada": "අඳ",
    "sthuthi": "ස්තූතියි",
    "awidinawa": "ඇවිදිනවා",
    "boru": "බොරු",
    "hawasa": "හවස",
    "irida": "ඉරිදා",
    "hodai": "හොඳයි",
    "narakai": "නරකයි",
    "saduda": "සඳුදා",
    "pata": "පාට",
    "udasana": "උදෑසන",
    // idle / unknown
    "idle": "",
    "UNKNOWN": "",
  };

  static String toSinhala(String label) {

    // If custom gesture already Sinhala
    if (RegExp(r'[අ-ෆ]').hasMatch(label)) {
      return label;
    }

    return gestureToSinhala[label] ?? label;
  }
}