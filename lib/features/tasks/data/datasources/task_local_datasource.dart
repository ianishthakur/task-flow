import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getTasksByCategory(String category);
  Future<TaskModel> getTaskById(String id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> searchTasks(String query);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final DatabaseHelper databaseHelper;
  
  TaskLocalDataSourceImpl({required this.databaseHelper});
  
  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'tasks',
        orderBy: 'created_at DESC',
      );
      return result.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch tasks: $e');
    }
  }
  
  @override
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
      return result.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch tasks by category: $e');
    }
  }
  
  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) {
        throw DatabaseException('Task not found');
      }
      return TaskModel.fromJson(result.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch task: $e');
    }
  }
  
  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('tasks', task.toJson());
      return task;
    } catch (e) {
      throw DatabaseException('Failed to create task: $e');
    }
  }
  
  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final db = await databaseHelper.database;
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await db.update(
        'tasks',
        updatedTask.toJson(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      return updatedTask;
    } catch (e) {
      throw DatabaseException('Failed to update task: $e');
    }
  }
  
  @override
  Future<void> deleteTask(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete task: $e');
    }
  }
  
  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'tasks',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      return result.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw DatabaseException('Failed to search tasks: $e');
    }
  }
}
