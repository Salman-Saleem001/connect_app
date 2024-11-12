class RecommendedPostsModel {
  RecommendedPostsModel({
    String? message,
    String? exception,
    String? file,
    int? line,
    List<Trace>? trace,
  }) {
    _message = message;
    _exception = exception;
    _file = file;
    _line = line;
    _trace = trace;
  }

  RecommendedPostsModel.fromJson(dynamic json) {
    _message = json['message'];
    _exception = json['exception'];
    _file = json['file'];
    _line = json['line'];
    if (json['trace'] != null) {
      _trace = [];
      json['trace'].forEach((v) {
        _trace?.add(Trace.fromJson(v));
      });
    }
  }
  String? _message;
  String? _exception;
  String? _file;
  int? _line;
  List<Trace>? _trace;

  RecommendedPostsModel copyWith({
    String? message,
    String? exception,
    String? file,
    int? line,
    List<Trace>? trace,
  }) =>
      RecommendedPostsModel(
        message: message ?? _message,
        exception: exception ?? _exception,
        file: file ?? _file,
        line: line ?? _line,
        trace: trace ?? _trace,
      );

  String? get message => _message;
  String? get exception => _exception;
  String? get file => _file;
  int? get line => _line;
  List<Trace>? get trace => _trace;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['exception'] = _exception;
    map['file'] = _file;
    map['line'] = _line;
    if (_trace != null) {
      map['trace'] = _trace?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class Trace {
  Trace({
    String? file,
    int? line,
    String? method,  // Renamed from 'function' to 'method'
    String? className,  // Renamed from 'class' to 'className'
    String? type,
  }) {
    _file = file;
    _line = line;
    _method = method;
    _className = className;
    _type = type;
  }

  Trace.fromJson(dynamic json) {
    _file = json['file'];
    _line = json['line'];
    _method = json['function'];  // Using the renamed variable 'method'
    _className = json['class'];  // Using the renamed variable 'className'
    _type = json['type'];
  }
  String? _file;
  int? _line;
  String? _method;
  String? _className;
  String? _type;

  Trace copyWith({
    String? file,
    int? line,
    String? method,
    String? className,
    String? type,
  }) =>
      Trace(
        file: file ?? _file,
        line: line ?? _line,
        method: method ?? _method,
        className: className ?? _className,
        type: type ?? _type,
      );

  String? get file => _file;
  int? get line => _line;
  String? get method => _method;
  String? get className => _className;
  String? get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['file'] = _file;
    map['line'] = _line;
    map['function'] = _method;  // Using the renamed variable 'method'
    map['class'] = _className;  // Using the renamed variable 'className'
    map['type'] = _type;
    return map;
  }
}
