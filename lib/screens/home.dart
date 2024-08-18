import 'dart:convert';
import 'dart:math';

import 'package:action_planner/constants/colors.dart';
import 'package:action_planner/model/todo.dart';
import 'package:action_planner/screens/Navbar.dart';
import 'package:action_planner/widgets/todo_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // firebase Setup
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final String serverUrl = 'http://10.0.2.2:3000';

  // final todosList = ToDo.todoList();
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _textController = TextEditingController();

  @override
  void initState() {
    // _foundToDo = todosList;
    super.initState();
    loadToDoList();

    // set the user
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  void loadToDoList() async {
    todosList = await fetchToDoListFromBackend();
    setState(() {
      _foundToDo = todosList;
    });
  }

  // Static method to fetch data from backend
  Future<List<ToDo>> fetchToDoListFromBackend() async {
    print(_user?.uid);
    if (_user != null) {
      final response =
          await http.get(Uri.parse('$serverUrl/api/v1/items?id=${_user?.uid}'));
      if (response.statusCode == 200) {
        final itemList = jsonDecode(response.body);
        final items =
            itemList.map<ToDo>((json) => ToDo.fromJson(json)).toList();
        return items;
      } else {
        // throw Exception("Failed to Fetch Items");
        return [];
      }
    } else {
      throw Exception("You are not Logged in");
      // return [];
    }
  }

  // Static method to Send data to backend
  Future<void> sendData() async {
    if (_user != null && _textController.text != "") {
      final String Url =
          '$serverUrl/api/v1/items'; // Update with your backend URL
      // Data to be sent
      final data = {
        'user_id': _user?.uid,
        'todos': [
          {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'todoText': _textController.text,
            'isDone': false
          }
        ]
      };

      try {
        final response = await http.post(
          Uri.parse(Url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          print('Success: ${response.body}');
        } else {
          print('Failed: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
      _textController.clear();
      loadToDoList();
    }
  }

  // cheklist update
  Future<void> UpdateCheckList(id, isdone) async {
    if (_user != null) {
      final String Url =
          '$serverUrl/api/v1/items'; // Update with your backend URL
      final data = {
        'user_id': _user?.uid,
        'todo_id': id,
        'isDone': isdone,
      };
      try {
        final response = await http.put(
          Uri.parse(Url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        if (response.statusCode == 200) {
          print('Success: ${response.body}');
          loadToDoList();
        } else {
          print('Failed: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // Delete todo
  Future<void> DeleteTodoList(todo_id) async {
    if (_user != null) {
      final String Url =
          '$serverUrl/api/v1/items/$todo_id'; // Update with your backend URL
      try {
        final data = {
          'user_id': _user?.uid,
        };
        final response = await http.delete(Uri.parse(Url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data));
        if (response.statusCode == 200) {
          print('Success: ${response.body}');
          loadToDoList();
        } else {
          print('Failed: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // handel google signin
  Future<void> handleGoogleSignIn() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Await the sign-in process
      await _auth.signInWithProvider(googleProvider);
    } catch (error) {
      print("Sign-in error: $error");
    }
  }

  // Method for handling search
  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  // Widget for search box
  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value), // Correctly calls _runFilter
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, maxWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      drawer: Navbar(
        user: _user,
        handleGoogleSignIn: handleGoogleSignIn,
      ),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // Search Box
            Container(
              decoration: BoxDecoration(
                color: tdBGColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    searchBox(), // Assuming searchBox() is a method that returns a widget
                    const SizedBox(
                        height:
                            15), // Add some spacing between search box and todos

                    // "All ToDos" text
                    Container(
                      margin: const EdgeInsets.only(left: 10, bottom: 20),
                      child: const Text(
                        'All ToDos',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FutureBuilder for fetching the ToDo list
            Expanded(
              child: FutureBuilder<List<ToDo>>(
                future: fetchToDoListFromBackend(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator()); // Show a loader
                  } else if (snapshot.hasError) {
                    return Center(
                        child:
                            Text('Error: ${snapshot.error}')); // Handle error
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(
                        child:
                            Text('No ToDos available')); // Handle empty state
                  } else if (snapshot.hasData) {
                    List<ToDo> _foundToDo = snapshot.data!;
                    return ListView(
                      children: [
                        for (ToDo todoo in _foundToDo.reversed)
                          ToDoItem(
                            todo: todoo,
                            onToDoChanged: (todo) {
                              UpdateCheckList(todoo.id, !todoo.isDone);
                            },
                            onDeleteItem: (id) {
                              // setState(() {
                              //   _foundToDo.removeWhere((item) => item.id == id);
                              // });
                              DeleteTodoList(id);
                            },
                          ),
                      ],
                    );
                  }
                  return Container(); // Fallback in case snapshot doesn't meet any conditions
                },
              ),
            ),

            // Add ToDo Item Row
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                            offset: Offset(0.0, 0.0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                            hintText: 'Add a new todo item',
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        sendData(); // Method to send the new ToDo
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tdBlue,
                        fixedSize: const Size(60, 60),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '+',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Text('Action Planner'), // Add your title here
      actions: [
        Container(
          height: 35,
          width: 35,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: _user != null
                  ? NetworkImage(_user?.photoURL ?? '')
                  : AssetImage('assets/images/avatar.jpg') as ImageProvider,
            ),
          ),
        ),
        SizedBox(
            width:
                16), // Optional: Add some space between the container and the edge
      ],
    );
  }

  // Helper method to add a new ToDo item
  void _addToDoItem(String toDo) {
    if (toDo != "") {
      setState(() {
        todosList.add(ToDo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            todoText: toDo));
      });
      _textController.clear();
    }
  }
}
