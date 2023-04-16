import 'package:crud_app/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All tasks
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  void _refreshTasks() async {
    final data = await SQLHelper.getTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingTask = _tasks.firstWhere((element) => element['id'] == id);
      _titleController.text = existingTask['title'];
      _descriptionController.text = existingTask['description'];
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Task Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  if (id == null) {
                    await _addItem();
                  } else {
                    await _updateItem(id);
                  }
                  // Clear the text fields
                  _titleController.text = '';
                  _descriptionController.text = '';
                  // Close the bottom sheet
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Title Required',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Please enter a title for your task.',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              child: Text(id == null ? 'Create Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    await SQLHelper.createTask(
        _titleController.text, _descriptionController.text);
    _refreshTasks();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateTask(
        id, _titleController.text, _descriptionController.text);

    _refreshTasks();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteTask(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a task!'),
    ));

    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Taskify",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        elevation: 0.0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(
                    _tasks[index]['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                      letterSpacing: 1.5,
                    ),
                  ),
                  subtitle: Text(
                    "${DateFormat('MMM dd, yyyy').format(DateTime.parse(_tasks[index]['createdAt'])).toString()}: ${_tasks[index]['description']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showForm(_tasks[index]['id']),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Task',
                          splashRadius: 24,
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: const <Widget>[
                                      Icon(Icons.warning, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Warning'),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text(
                                          'Are you sure you want to delete this task?'),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          TextButton.icon(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.grey),
                                            label: const Text('CANCEL'),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              _deleteItem(_tasks[index]['id']);
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.task_alt,
                                                color: Colors.red),
                                            label: const Text('DELETE'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.add_task, color: Colors.black),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
