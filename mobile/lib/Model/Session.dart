class Session {
  int? sessionId;
  int? userId;
  String? userFullname;
  String? startTime;
  String? endTime;
  String? lastUpdateTime;
  int? openingCash;
  int? totalIncome;
  int? expectedClosingCash;
  int? actualClosingCash;
  int? actualDifference;
  int? depositMoney;
  int? depositDifference;
  String? openingNotes;
  String? closingNotes;

  Session(
      {this.sessionId,
      this.userId,
      this.userFullname,
      this.startTime,
      this.endTime,
      this.lastUpdateTime,
      this.openingCash,
      this.totalIncome,
      this.expectedClosingCash,
      this.actualClosingCash,
      this.actualDifference,
      this.depositMoney,
      this.depositDifference,
      this.openingNotes,
      this.closingNotes});

  Session.fromJson(Map<String, dynamic> json) {
    sessionId = json['session_id'];
    userId = json['user_id'];
    userFullname = json['user_fullname'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    lastUpdateTime = json['last_update_time'];
    openingCash = json['opening_cash'];
    totalIncome = json['total_income'];
    expectedClosingCash = json['expected_closing_cash'];
    actualClosingCash = json['actual_closing_cash'];
    actualDifference = json['actual_difference'];
    depositMoney = json['deposit_money'];
    depositDifference = json['deposit_difference'];
    openingNotes = json['opening_notes'];
    closingNotes = json['closing_notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['session_id'] = this.sessionId;
    data['user_id'] = this.userId;
    data['user_fullname'] = this.userFullname;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['last_update_time'] = this.lastUpdateTime;
    data['opening_cash'] = this.openingCash;
    data['total_income'] = this.totalIncome;
    data['expected_closing_cash'] = this.expectedClosingCash;
    data['actual_closing_cash'] = this.actualClosingCash;
    data['actual_difference'] = this.actualDifference;
    data['deposit_money'] = this.depositMoney;
    data['deposit_difference'] = this.depositDifference;
    data['opening_notes'] = this.openingNotes;
    data['closing_notes'] = this.closingNotes;
    return data;
  }
}
