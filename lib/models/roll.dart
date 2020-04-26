class Roll {
  String id;
  int result;
  String userId;
  bool shouldOnlyShowResult;
  String rolled;
  DateTime rolledAt;

  Roll({this.id, this.result, this.userId, this.shouldOnlyShowResult, this.rolled, this.rolledAt});

  Roll.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          result: json['result'],
          userId: json['userId'],
          shouldOnlyShowResult: json['shouldOnlyShowResult'],
          rolled: json['rolled'],
          rolledAt: json['rolledAt'],
        );

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'userId': userId,
      'rolled': rolled,
      'shouldOnlyShowResults': shouldOnlyShowResult,
      'rolledAt': rolledAt,
    };
  }
}

class User {
  String id;
  String name;
  int icon;
  int color;
  bool isDM;

  User({this.id, this.name, this.isDM, this.icon, this.color});

  User.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          name: json['name'],
          isDM: json['isDM'],
          icon: json['icon'],
          color: json['color'],
        );
}
