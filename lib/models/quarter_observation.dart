import 'dart:convert';

class QuarterObservation {
  final String id;
  final String quarterTitle;
  final String content;
  final String date;
  bool isExpanded;

  QuarterObservation({
    required this.id,
    required this.quarterTitle,
    required this.content,
    required this.date,
    this.isExpanded = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'quarterTitle': quarterTitle,
        'content': content,
        'date': date,
      };

  factory QuarterObservation.fromJson(Map<String, dynamic> json) =>
      QuarterObservation(
        id: json['id'] ?? '',
        quarterTitle: json['quarterTitle'] ?? '',
        content: json['content'] ?? '',
        date: json['date'] ?? '',
      );

  static String encodeList(List<QuarterObservation> list) =>
      json.encode(list.map((item) => item.toJson()).toList());

  static List<QuarterObservation> decodeList(String str) {
    if (str.isEmpty) return [];
    final List<dynamic> jsonList = json.decode(str);
    return jsonList.map((item) => QuarterObservation.fromJson(item)).toList();
  }
}
