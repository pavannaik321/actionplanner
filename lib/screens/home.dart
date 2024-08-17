import 'dart:math';

import 'package:action_planner/constants/colors.dart';
import 'package:action_planner/model/todo.dart';
import 'package:action_planner/screens/Navbar.dart';
import 'package:action_planner/widgets/todo_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // firebase Setup
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _textController = TextEditingController();

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();

    // set the user
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  searchBox(),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              top: 50, bottom: 20, left: 10),
                          child: const Text(
                            'All ToDos',
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w500),
                          ),
                        ),
                        for (ToDo todoo in _foundToDo.reversed)
                          ToDoItem(
                            todo: todoo,
                            onToDoChanged: (todo) {
                              setState(() {
                                todo.isDone = !todo.isDone;
                              });
                            },
                            onDeleteItem: (id) {
                              setState(() {
                                todosList.removeWhere((item) => item.id == id);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 20, left: 20, right: 20),
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
                    margin: const EdgeInsets.only(bottom: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        _addToDoItem(_textController.text);
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  )
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
