class FetchSession {
  int? _status;
  String? _message;
  List<Data>? _data;

  FetchSession({int? status, String? message, List<Data>? data}) {
    if (status != null) {
      this._status = status;
    }
    if (message != null) {
      this._message = message;
    }
    if (data != null) {
      this._data = data;
    }
  }

  int? get status => _status;
  set status(int? status) => _status = status;
  String? get message => _message;
  set message(String? message) => _message = message;
  List<Data>? get data => _data;
  set data(List<Data>? data) => _data = data;

  FetchSession.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = <Data>[];
      json['data'].forEach((v) {
        _data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this._status;
    data['message'] = this._message;
    if (this._data != null) {
      data['data'] = this._data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? _sessionId;
  int? _userId;
  String? _userFullname;
  String? _startTime;
  String? _endTime;
  String? _lastUpdateTime;
  int? _openingCash;
  int? _totalIncome;
  int? _expectedClosingCash;
  int? _actualClosingCash;
  int? _actualDifference;
  int? _depositMoney;
  int? _depositDifference;
  String? _openingNotes;
  String? _closingNotes;

  Data(
      {int? sessionId,
      int? userId,
      String? userFullname,
      String? startTime,
      String? endTime,
      String? lastUpdateTime,
      int? openingCash,
      int? totalIncome,
      int? expectedClosingCash,
      int? actualClosingCash,
      int? actualDifference,
      int? depositMoney,
      int? depositDifference,
      String? openingNotes,
      String? closingNotes}) {
    if (sessionId != null) {
      this._sessionId = sessionId;
    }
    if (userId != null) {
      this._userId = userId;
    }
    if (userFullname != null) {
      this._userFullname = userFullname;
    }
    if (startTime != null) {
      this._startTime = startTime;
    }
    if (endTime != null) {
      this._endTime = endTime;
    }
    if (lastUpdateTime != null) {
      this._lastUpdateTime = lastUpdateTime;
    }
    if (openingCash != null) {
      this._openingCash = openingCash;
    }
    if (totalIncome != null) {
      this._totalIncome = totalIncome;
    }
    if (expectedClosingCash != null) {
      this._expectedClosingCash = expectedClosingCash;
    }
    if (actualClosingCash != null) {
      this._actualClosingCash = actualClosingCash;
    }
    if (actualDifference != null) {
      this._actualDifference = actualDifference;
    }
    if (depositMoney != null) {
      this._depositMoney = depositMoney;
    }
    if (depositDifference != null) {
      this._depositDifference = depositDifference;
    }
    if (openingNotes != null) {
      this._openingNotes = openingNotes;
    }
    if (closingNotes != null) {
      this._closingNotes = closingNotes;
    }
  }

  int? get sessionId => _sessionId;
  set sessionId(int? sessionId) => _sessionId = sessionId;
  int? get userId => _userId;
  set userId(int? userId) => _userId = userId;
  String? get userFullname => _userFullname;
  set userFullname(String? userFullname) => _userFullname = userFullname;
  String? get startTime => _startTime;
  set startTime(String? startTime) => _startTime = startTime;
  String? get endTime => _endTime;
  set endTime(String? endTime) => _endTime = endTime;
  String? get lastUpdateTime => _lastUpdateTime;
  set lastUpdateTime(String? lastUpdateTime) =>
      _lastUpdateTime = lastUpdateTime;
  int? get openingCash => _openingCash;
  set openingCash(int? openingCash) => _openingCash = openingCash;
  int? get totalIncome => _totalIncome;
  set totalIncome(int? totalIncome) => _totalIncome = totalIncome;
  int? get expectedClosingCash => _expectedClosingCash;
  set expectedClosingCash(int? expectedClosingCash) =>
      _expectedClosingCash = expectedClosingCash;
  int? get actualClosingCash => _actualClosingCash;
  set actualClosingCash(int? actualClosingCash) =>
      _actualClosingCash = actualClosingCash;
  int? get actualDifference => _actualDifference;
  set actualDifference(int? actualDifference) =>
      _actualDifference = actualDifference;
  int? get depositMoney => _depositMoney;
  set depositMoney(int? depositMoney) => _depositMoney = depositMoney;
  int? get depositDifference => _depositDifference;
  set depositDifference(int? depositDifference) =>
      _depositDifference = depositDifference;
  String? get openingNotes => _openingNotes;
  set openingNotes(String? openingNotes) => _openingNotes = openingNotes;
  String? get closingNotes => _closingNotes;
  set closingNotes(String? closingNotes) => _closingNotes = closingNotes;

  Data.fromJson(Map<String, dynamic> json) {
    _sessionId = json['session_id'];
    _userId = json['user_id'];
    _userFullname = json['user_fullname'];
    _startTime = json['start_time'];
    _endTime = json['end_time'];
    _lastUpdateTime = json['last_update_time'];
    _openingCash = json['opening_cash'];
    _totalIncome = json['total_income'];
    _expectedClosingCash = json['expected_closing_cash'];
    _actualClosingCash = json['actual_closing_cash'];
    _actualDifference = json['actual_difference'];
    _depositMoney = json['deposit_money'];
    _depositDifference = json['deposit_difference'];
    _openingNotes = json['opening_notes'];
    _closingNotes = json['closing_notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['session_id'] = this._sessionId;
    data['user_id'] = this._userId;
    data['user_fullname'] = this._userFullname;
    data['start_time'] = this._startTime;
    data['end_time'] = this._endTime;
    data['last_update_time'] = this._lastUpdateTime;
    data['opening_cash'] = this._openingCash;
    data['total_income'] = this._totalIncome;
    data['expected_closing_cash'] = this._expectedClosingCash;
    data['actual_closing_cash'] = this._actualClosingCash;
    data['actual_difference'] = this._actualDifference;
    data['deposit_money'] = this._depositMoney;
    data['deposit_difference'] = this._depositDifference;
    data['opening_notes'] = this._openingNotes;
    data['closing_notes'] = this._closingNotes;
    return data;
  }
}
