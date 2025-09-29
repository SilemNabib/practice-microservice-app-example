'use strict';
const {Annotation, 
    jsonEncoder: {JSON_V2}} = require('zipkin');

const OPERATION_CREATE = 'CREATE',
      OPERATION_DELETE = 'DELETE';

class TodoController {
    constructor({tracer, redisClient, logChannel, db}) {
        this._tracer = tracer;
        this._redisClient = redisClient;
        this._logChannel = logChannel;
        this._db = db;
        this._collection = db.collection('todos');
    }

    async list (req, res) {
        try {
            const todos = await this._collection.find({ username: req.user.username }).toArray();
            const todoItems = todos.reduce((acc, todo) => {
                acc[todo.id] = { id: todo.id, content: todo.content };
                return acc;
            }, {});
            
            res.json(Object.values(todoItems));
        } catch (error) {
            console.error('Error listing todos:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async create (req, res) {
        try {
            // Get the next ID for this user
            const lastTodo = await this._collection.findOne(
                { username: req.user.username },
                { sort: { id: -1 } }
            );
            
            const nextId = lastTodo ? lastTodo.id + 1 : 1;
            
            const todo = {
                id: nextId,
                content: req.body.content,
                username: req.user.username,
                createdAt: new Date()
            };

            await this._collection.insertOne(todo);
            
            this._logOperation(OPERATION_CREATE, req.user.username, todo.id);

            res.json({ id: todo.id, content: todo.content });
        } catch (error) {
            console.error('Error creating todo:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async delete (req, res) {
        try {
            const id = parseInt(req.params.taskId);
            const result = await this._collection.deleteOne({
                id: id,
                username: req.user.username
            });

            if (result.deletedCount === 0) {
                return res.status(404).json({ error: 'Todo not found' });
            }

            this._logOperation(OPERATION_DELETE, req.user.username, id);

            res.status(204).send();
        } catch (error) {
            console.error('Error deleting todo:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    _logOperation (opName, username, todoId) {
        this._tracer.scoped(() => {
            const traceId = this._tracer.id;
            this._redisClient.publish(this._logChannel, JSON.stringify({
                zipkinSpan: traceId,
                opName: opName,
                username: username,
                todoId: todoId,
            }))
        })
    }
}

module.exports = TodoController