import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskItem {
  final int? id;
  final String title;
  final DateTime? alertTime;
  final String recurrence;
  final bool isCompleted;
  final String? createdAt;

  TaskItem({
    this.id,
    required this.title,
    this.alertTime,
    this.recurrence = 'once',
    this.isCompleted = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'alert_time': alertTime?.toIso8601String(),
        'recurrence': recurrence,
        'is_completed': isCompleted ? 1 : 0,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory TaskItem.fromMap(Map<String, dynamic> map) => TaskItem(
        id: map['id'],
        title: map['title'] ?? '',
        alertTime: map['alert_time'] != null
            ? DateTime.tryParse(map['alert_time'])
            : null,
        recurrence: map['recurrence'] ?? 'once',
        isCompleted: (map['is_completed'] ?? 0) == 1,
        createdAt: map['created_at'],
      );

  TaskItem copyWith({
    int? id,
    String? title,
    DateTime? alertTime,
    String? recurrence,
    bool? isCompleted,
    String? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      alertTime: alertTime ?? this.alertTime,
      recurrence: recurrence ?? this.recurrence,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TaskProvider extends ChangeNotifier {
  List<TaskItem> _tasks = [];
  bool _isLoading = false;

  List<TaskItem> get activeTasks =>
      _tasks.where((t) => !t.isCompleted).toList();
  List<TaskItem> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseService();
      final rows = await db.query('tasks', orderBy: 'created_at DESC');
      _tasks = rows.map((r) => TaskItem.fromMap(r)).toList();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    final db = DatabaseService();
    final id = await db.insert('tasks', task.toMap());
    _tasks.insert(0, task.copyWith(id: id));

    if (task.alertTime != null) {
      await NotificationService()
          .scheduleTaskNotification(id, task.title, task.alertTime!);
    }

    notifyListeners();
  }

  Future<void> toggleComplete(int taskId) async {
    final db = DatabaseService();
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final newStatus = !task.isCompleted;
    await db.update('tasks', {'is_completed': newStatus ? 1 : 0},
        where: 'id = ?', whereArgs: [taskId]);

    _tasks[index] = task.copyWith(isCompleted: newStatus);

    if (newStatus) {
      await NotificationService().cancelNotification(taskId);
    }

    notifyListeners();
  }

  Future<void> deleteTask(int taskId) async {
    final db = DatabaseService();
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    _tasks.removeWhere((t) => t.id == taskId);
    await NotificationService().cancelNotification(taskId);
    notifyListeners();
  }
}
