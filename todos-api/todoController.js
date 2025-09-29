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
        this._cacheExpiry = 300; // 5 minutes cache expiry
    }

    // Cache key generators
    _getUserTodosKey(username) {
        return `todos:user:${username}`;
    }

    _getTodoKey(username, todoId) {
        return `todo:${username}:${todoId}`;
    }

    // Cache helper methods
    async _getFromCache(key) {
        return new Promise((resolve, reject) => {
            console.log(`[CACHE-ASIDE] Attempting to GET from cache: ${key}`);
            this._redisClient.get(key, (err, result) => {
                if (err) {
                    console.error(`[CACHE-ASIDE] Redis GET error for key ${key}:`, err);
                    resolve(null); // Return null on error to fallback to DB
                } else {
                    if (result) {
                        console.log(`[CACHE-ASIDE] ✅ Cache HIT for key: ${key}`);
                    } else {
                        console.log(`[CACHE-ASIDE] ❌ Cache MISS for key: ${key}`);
                    }
                    resolve(result ? JSON.parse(result) : null);
                }
            });
        });
    }

    async _setCache(key, data, expiry = this._cacheExpiry) {
        return new Promise((resolve) => {
            console.log(`[CACHE-ASIDE] Setting cache for key: ${key} (expiry: ${expiry}s)`);
            this._redisClient.setex(key, expiry, JSON.stringify(data), (err) => {
                if (err) {
                    console.error(`[CACHE-ASIDE] Redis SET error for key ${key}:`, err);
                } else {
                    console.log(`[CACHE-ASIDE] ✅ Successfully cached data for key: ${key}`);
                }
                resolve(); // Always resolve to not block the main flow
            });
        });
    }

    async _deleteFromCache(key) {
        return new Promise((resolve) => {
            console.log(`[CACHE-ASIDE] Deleting from cache: ${key}`);
            this._redisClient.del(key, (err) => {
                if (err) {
                    console.error(`[CACHE-ASIDE] Redis DEL error for key ${key}:`, err);
                } else {
                    console.log(`[CACHE-ASIDE] ✅ Successfully deleted cache for key: ${key}`);
                }
                resolve();
            });
        });
    }

    async _invalidateUserCache(username) {
        console.log(`[CACHE-ASIDE] Invalidating cache for user: ${username}`);
        const userTodosKey = this._getUserTodosKey(username);
        await this._deleteFromCache(userTodosKey);
    }

    async list (req, res) {
        try {
            const username = req.user.username;
            const cacheKey = this._getUserTodosKey(username);
            
            console.log(`[CACHE-ASIDE] LIST operation for user: ${username}`);
            
            // Try to get from cache first (Cache-Aside pattern)
            let cachedTodos = await this._getFromCache(cacheKey);
            
            if (cachedTodos) {
                console.log(`[CACHE-ASIDE] Returning cached todos for user: ${username} (${cachedTodos.length} items)`);
                return res.json(cachedTodos);
            }
            
            console.log(`[CACHE-ASIDE] Fetching todos from database for user: ${username}`);
            
            // If not in cache, get from database
            const todos = await this._collection.find({ username: username }).toArray();
            const todoItems = todos.reduce((acc, todo) => {
                acc[todo.id] = { id: todo.id, content: todo.content };
                return acc;
            }, {});
            
            const todoList = Object.values(todoItems);
            console.log(`[CACHE-ASIDE] Found ${todoList.length} todos in database for user: ${username}`);
            
            // Store in cache for future requests
            await this._setCache(cacheKey, todoList);
            
            res.json(todoList);
        } catch (error) {
            console.error('Error listing todos:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async create (req, res) {
        try {
            const username = req.user.username;
            
            console.log(`[CACHE-ASIDE] CREATE operation for user: ${username}`);
            
            // Get the next ID for this user
            const lastTodo = await this._collection.findOne(
                { username: username },
                { sort: { id: -1 } }
            );
            
            const nextId = lastTodo ? lastTodo.id + 1 : 1;
            
            const todo = {
                id: nextId,
                content: req.body.content,
                username: username,
                createdAt: new Date()
            };

            // Insert into database first
            console.log(`[CACHE-ASIDE] Inserting new todo (ID: ${nextId}) into database for user: ${username}`);
            await this._collection.insertOne(todo);
            
            // Invalidate user's todos cache (Write-Around pattern)
            console.log(`[CACHE-ASIDE] Applying Write-Around pattern - invalidating cache after CREATE`);
            await this._invalidateUserCache(username);
            
            this._logOperation(OPERATION_CREATE, username, todo.id);

            res.json({ id: todo.id, content: todo.content });
        } catch (error) {
            console.error('Error creating todo:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async delete (req, res) {
        try {
            const id = parseInt(req.params.taskId);
            const username = req.user.username;
            
            console.log(`[CACHE-ASIDE] DELETE operation for user: ${username}, todo ID: ${id}`);
            
            const result = await this._collection.deleteOne({
                id: id,
                username: username
            });

            if (result.deletedCount === 0) {
                console.log(`[CACHE-ASIDE] Todo not found for deletion - ID: ${id}, user: ${username}`);
                return res.status(404).json({ error: 'Todo not found' });
            }

            console.log(`[CACHE-ASIDE] Successfully deleted todo (ID: ${id}) from database for user: ${username}`);
            
            // Invalidate user's todos cache (Write-Around pattern)
            console.log(`[CACHE-ASIDE] Applying Write-Around pattern - invalidating cache after DELETE`);
            await this._invalidateUserCache(username);

            this._logOperation(OPERATION_DELETE, username, id);

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