const mongoose = require('mongoose');

// Define the schema for User with embedded ToDo items
const userSchema = new mongoose.Schema({
  user_id: { type: String, required: true }, // Store Firebase user ID or any unique identifier
  todos: [
    {
      id: { type: String, required: true },      // Unique ID for each ToDo item
      todoText: { type: String, required: true }, // Text of the ToDo item
      isDone: { type: Boolean, default: false }   // Status of the ToDo item
    }
  ]
});

// Create a model from the schema
const User = mongoose.model('User', userSchema);

module.exports = User;
