// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

contract TodoList{
    struct Todo{
        string text;
        bool completed;
    }

    Todo[] public todos;
    function create(string calldata _text) external{
        todos.push(Todo({
            text:_text,
            completed:false
        }));
    }
    function updateText(uint _index, string calldata _text) external{
        // First Way. Cheaper on gas if one field needed to update
        todos[_index].text=_text;

        // Second way. Cheaper on gas if muliple fields are needed to update
        // Todo storage todo = todos[_index];
        // todo.text=_text;
    }

    function get(uint _index)external view returns (string memory, bool){
        // Using memory requires copying of data, so it isn't gas efficient. 
        // Using storage is 
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }
    function toggleCompleted(uint _index) external{
        todos[_index].completed=!todos[_index].completed;
    }
}