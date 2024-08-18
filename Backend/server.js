const express = require('express');
const mongoose = require('mongoose')
//app configuration
const app = express();
const port = 3000;

//middleware configuration
app.use(express.json());

//configure mongodb
mongoose.connect("mongodb+srv://hairwayon2024:Pavan21p5959@cluster0.zqxqw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0").then(() => {
    console.log('MongoDB connected');
  }).catch((error) => {
    console.error('MongoDB connection error:', error);
  });

  const User = require('./models/todoSchema');

//Model 
// let usersList = [
//     {
//       user_id: '1',
//       todos: [
//         { id: '01', todoText: 'Buy milk', isDone: true },
//         { id: '02', todoText: 'Walk the dog', isDone: true },
//         { id: '03', todoText: 'Do laundry', isDone: false },
//         { id: '04', todoText: 'Clean the house', isDone: false },
//         { id: '05', todoText: 'Cook dinner', isDone: false }
//       ]
//     },
//     {
//       user_id: '2',
//       todos: [
//         { id: '06', todoText: 'Finish project', isDone: false },
//         { id: '07', todoText: 'Exercise', isDone: true },
//         { id: '08', todoText: 'Read a book', isDone: false }
//       ]
//     },
//     {
//       user_id: '3',
//       todos: [
//         { id: '09', todoText: 'Plan vacation', isDone: true },
//         { id: '10', todoText: 'Grocery shopping', isDone: false },
//         { id: '11', todoText: 'Fix the car', isDone: false },
//         { id: '12', todoText: 'Call parents', isDone: true }
//       ]
//     },
//     {
//       user_id: '4',
//       todos: [
//         { id: '13', todoText: 'Attend meeting', isDone: false },
//         { id: '14', todoText: 'Complete assignment', isDone: true },
//         { id: '15', todoText: 'Pay bills', isDone: true }
//       ]
//     },
//     {
//       user_id: '5',
//       todos: [
//         { id: '16', todoText: 'Walk the cat', isDone: false },
//         { id: '17', todoText: 'Water plants', isDone: true },
//         { id: '18', todoText: 'Organize closet', isDone: false }
//       ]
//     },
//     {
//       user_id: '6',
//       todos: [
//         { id: '19', todoText: 'Buy groceries', isDone: false },
//         { id: '20', todoText: 'Plan birthday party', isDone: true },
//         { id: '21', todoText: 'Watch a movie', isDone: false }
//       ]
//     },
//     {
//       user_id: '7',
//       todos: [
//         { id: '22', todoText: 'Prepare presentation', isDone: true },
//         { id: '23', todoText: 'Clean kitchen', isDone: false },
//         { id: '24', todoText: 'Visit friend', isDone: false }
//       ]
//     },
//     {
//       user_id: '8',
//       todos: [
//         { id: '25', todoText: 'Work on side project', isDone: false },
//         { id: '26', todoText: 'Practice coding', isDone: true },
//         { id: '27', todoText: 'Cook new recipe', isDone: false }
//       ]
//     },
//     {
//       user_id: '9',
//       todos: [
//         { id: '28', todoText: 'Schedule doctor appointment', isDone: false },
//         { id: '29', todoText: 'Buy new shoes', isDone: true },
//         { id: '30', todoText: 'Write blog post', isDone: false }
//       ]
//     },
//     {
//       user_id: '10',
//       todos: [
//         { id: '31', todoText: 'Go hiking', isDone: true },
//         { id: '32', todoText: 'Start meditation', isDone: false },
//         { id: '33', todoText: 'Declutter workspace', isDone: true }
//       ]
//     }
//   ];
  
  

//api routes


app.get('/api/v1/items/', async (req, res) => {
  try {
    const userId = req.query.id; // Get user_id from query parameters
    console.log(`Fetching todos for user: ${userId}`);
    
    // Check if user exists in the database
    let user = await User.findOne({ user_id: userId });

    // If user doesn't exist, create a new user with an empty todos list
    if (!user) {
      console.log(`User not found. Creating new user with ID: ${userId}`);
      user = new User({
        user_id: userId,
        todos: [] // Initialize with an empty todos list
      });

      // Save the new user to the database
      await user.save();
    }

    // Return the user's todos (which may be empty if newly created)
    return res.status(200).json(user.todos);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Server error' });
  }
});



app.post('/api/v1/items', async (req, res) => {
  try {
    const { user_id, todos } = req.body;

    // Validate data if needed
    if (!user_id || !todos || !Array.isArray(todos) || todos.length === 0) {
      return res.status(400).json({ message: 'User ID and valid todos are required' });
    }

    // Find the user by user_id
    const existingUser = await User.findOne({ user_id });

    if (existingUser) {
      // If user exists, push new todos to the existing todos array
      existingUser.todos.push(...todos);
      await existingUser.save();
      return res.status(200).json({ message: 'Todo item(s) added successfully', data: existingUser });
    } else {
      // If user does not exist, create a new user with todos
      const newUser = new User({ user_id, todos });
      await newUser.save();
      return res.status(201).json({ message: 'User and Todo item(s) created successfully', data: newUser });
    }
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ message: 'Internal Server Error' });
  }
});


app.put('/api/v1/items', async (req, res) => {
  try {
    const { user_id, todo_id, isDone } = req.body;

    if (!user_id || !todo_id || typeof isDone !== 'boolean') {
      return res.status(400).json({ message: 'Invalid data' });
    }

    // Find the user by user_id
    const user = await User.findOne({ user_id: user_id });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Find the todo item within the user's todos array
    const todo = user.todos.find(todo => todo.id === todo_id);

    if (!todo) {
      return res.status(404).json({ message: 'Todo item not found' });
    }

    // Update the isDone status
    todo.isDone = isDone;

    // Save the updated user document
    await user.save();

    return res.status(200).json({ message: 'Todo item updated successfully' });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ message: 'Internal Server Error' });
  }
});
// Delete ToDo route
app.delete('/api/v1/items/:todo_id', async (req, res) => {
  try {
    const { todo_id } = req.params;
    const { user_id } = req.body; // Assuming you are sending user_id in the body

    if (!todo_id || !user_id) {
      return res.status(400).json({ message: 'User ID and ToDo ID are required' });
    }

    // Find the user by user_id
    const user = await User.findOne({ user_id: user_id });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Use pull to remove the todo item by its id
    const result = await User.updateOne(
      { user_id: user_id },
      { $pull: { todos: { id: todo_id } } }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ message: 'Todo item not found' });
    }

    return res.status(200).json({ message: 'Todo item deleted successfully' });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ message: 'Internal Server Error' });
  }
});

//listners
app.listen(port,()=>{
    console.log(`server is running on port ${port}`);
})