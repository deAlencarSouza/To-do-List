import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = List();
  TextEditingController _typedUserTaskController = TextEditingController();
  Map<String, dynamic> _lastRemovedUserTask = Map();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  void _saveTask() {
    Map<String, dynamic> userTask = Map();
    userTask['task'] = _typedUserTaskController.text;
    userTask['status'] = false;
    setState(() {
      _toDoList.add(userTask);
    });
    writeContent();
    _typedUserTaskController.text = '';
  }

  void writeContent() async {
    String jsonData = json.encode(_toDoList);
    final file = await _localFile;
    file.writeAsString(jsonData);
  }

  Future readContent() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      return 'error';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readContent().then((value) {
      setState(() {
        _toDoList = value;
      });
    });
  }

  Widget _showToDoList(context, index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        _lastRemovedUserTask = _toDoList[index];

        _toDoList.removeAt(index);
        writeContent();

        final snackbar = SnackBar(
          content: Text('Tarefa removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              setState(() {
                _toDoList.insert(index, _lastRemovedUserTask);
              });
              writeContent();
            },
          ),
        );

        Scaffold.of(context).showSnackBar(snackbar);
      },
      child: CheckboxListTile(
        title: Text(
          _toDoList[index]['task'],
        ),
        value: _toDoList[index]['status'],
        onChanged: (value) {
          setState(() {
            _toDoList[index]['status'] = value;
          });
          writeContent();
        },
        activeColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de tarefas',
        ),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: ListView.builder(
            itemCount: _toDoList.length, itemBuilder: _showToDoList),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Adicionar tarefa',
              ),
              content: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Digite sua tarefa',
                ),
                controller: _typedUserTaskController,
              ),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveTask();
                  },
                  child: Text('Salvar'),
                ),
              ],
            ),
          );
        },
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
