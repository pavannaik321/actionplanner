class ToDo {
  String? id;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Buy milk', isDone: true),
      ToDo(id: '02', todoText: 'Walk the dog', isDone: true),
      ToDo(id: '03', todoText: 'Do laundry'),
      ToDo(id: '04', todoText: 'Clean the house'),
      ToDo(id: '05', todoText: 'Cook dinner'),
      ToDo(
        id: '06',
        todoText: 'Buy groceries',
      ),
    ];
  }
}
