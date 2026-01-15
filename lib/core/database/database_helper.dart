import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'taskflow.db';
  static const int _databaseVersion = 1; // While migrating changed from 1 to 2

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create initial schema
    await _createInitialSchema(db);

    // Apply all migrations for fresh installs
    // This ensures new installs have the same schema as upgraded installs
    for (int v = 2; v <= version; v++) {
      await _runMigration(db, v);
    }
  }

  Future<void> _createInitialSchema(Database db) async {
    // Tasks table (v1 schema)
    await db.execute('''
    CREATE TABLE tasks (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      priority INTEGER NOT NULL DEFAULT 0,
      is_completed INTEGER NOT NULL DEFAULT 0,
      due_date TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

    // Categories table
    await db.execute('''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      color TEXT NOT NULL,
      icon TEXT,
      created_at TEXT NOT NULL
    )
  ''');

    // Indexes
    await db.execute('CREATE INDEX idx_tasks_category ON tasks(category)');
    await db.execute(
      'CREATE INDEX idx_tasks_is_completed ON tasks(is_completed)',
    );
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');

    // Default categories
    final now = DateTime.now().toIso8601String();
    for (final cat in [
      {
        'id': 'personal',
        'name': 'Personal',
        'color': '0xFF6366F1',
        'icon': 'user',
      },
      {
        'id': 'work',
        'name': 'Work',
        'color': '0xFFF59E0B',
        'icon': 'briefcase',
      },
      {
        'id': 'health',
        'name': 'Health',
        'color': '0xFF10B981',
        'icon': 'heart',
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'color': '0xFFEC4899',
        'icon': 'shopping-bag',
      },
    ]) {
      await db.insert('categories', {...cat, 'created_at': now});
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Run migrations sequentially from oldVersion to newVersion
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _runMigration(db, version);
    }
  }

  Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        // Example: Add a notes field to tasks
        await db.execute('ALTER TABLE tasks ADD COLUMN notes TEXT');
        break;

      case 3:
        // Example: Add reminder support
        await db.execute('ALTER TABLE tasks ADD COLUMN reminder_time TEXT');
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN has_reminder INTEGER NOT NULL DEFAULT 0',
        );
        break;

      case 4:
        // Example: Add subtasks table
        await db.execute('''
        CREATE TABLE subtasks (
          id TEXT PRIMARY KEY,
          task_id TEXT NOT NULL,
          title TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          position INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
        )
      ''');
        await db.execute(
          'CREATE INDEX idx_subtasks_task_id ON subtasks(task_id)',
        );
        break;

      case 5:
        // Example: Add tags support
        await db.execute('''
        CREATE TABLE tags (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL UNIQUE,
          color TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
        await db.execute('''
        CREATE TABLE task_tags (
          task_id TEXT NOT NULL,
          tag_id TEXT NOT NULL,
          PRIMARY KEY (task_id, tag_id),
          FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
        )
      ''');
        break;

      case 6:
        // Example: Add recurring tasks support
        await db.execute('ALTER TABLE tasks ADD COLUMN recurrence_rule TEXT');
        await db.execute('ALTER TABLE tasks ADD COLUMN parent_task_id TEXT');
        break;

      case 7:
        // Rename 'category' to 'category_id' - include ALL columns from previous migrations
        await db.execute('''
        CREATE TABLE tasks_new (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          category_id TEXT NOT NULL,
          priority INTEGER NOT NULL DEFAULT 0,
          is_completed INTEGER NOT NULL DEFAULT 0,
          due_date TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          notes TEXT,
          reminder_time TEXT,
          has_reminder INTEGER NOT NULL DEFAULT 0,
          recurrence_rule TEXT,
          parent_task_id TEXT,
          FOREIGN KEY (category_id) REFERENCES categories(id)
        )
      ''');
        // Copy data - column order must match
        await db.execute('''
        INSERT INTO tasks_new 
        SELECT id, title, description, category, priority, is_completed, 
               due_date, created_at, updated_at, notes, reminder_time, 
               has_reminder, recurrence_rule, parent_task_id
        FROM tasks
      ''');
        await db.execute('DROP TABLE tasks');
        await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
        // Recreate indexes
        await db.execute(
          'CREATE INDEX idx_tasks_category ON tasks(category_id)',
        );
        await db.execute(
          'CREATE INDEX idx_tasks_is_completed ON tasks(is_completed)',
        );
        await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
        break;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
