'use strict';
const {Annotation, 
    jsonEncoder: {JSON_V2}} = require('zipkin');

const OPERATION_CREATE = 'CREATE',
      OPERATION_DELETE = 'DELETE';

class TodoController {
    constructor({tracer, redisClient, logChannel}) {
        this._tracer = tracer;
        this._redisClient = redisClient;
        this._logChannel = logChannel;
        
        // Cache TTL configuration (from environment variables)
        this._cacheTTL = {
            default: parseInt(process.env.CACHE_TTL_DEFAULT) || 300,
            todoData: parseInt(process.env.CACHE_TTL_TODO_DATA) || 180,
            userData: parseInt(process.env.CACHE_TTL_USER_DATA) || 600
        };
        
        console.log('TodoController initialized with TTL config:', this._cacheTTL);
    }

    // Cache Aside Pattern Implementation
    async list(req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            res.json(data.items);
        } catch (error) {
            console.error('Error in list:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async create(req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            const todo = {
                content: req.body.content,
                id: data.lastInsertedID
            };
            
            data.items[data.lastInsertedID] = todo;
            data.lastInsertedID++;
            
            await this._setTodoData(req.user.username, data);
            
            this._logOperation(OPERATION_CREATE, req.user.username, todo.id);
            
            res.status(201).json(todo);
        } catch (error) {
            console.error('Error in create:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async delete(req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            const id = req.params.taskId;
            
            if (data.items[id]) {
                delete data.items[id];
                await this._setTodoData(req.user.username, data);
                
                this._logOperation(OPERATION_DELETE, req.user.username, id);
                
                res.status(204).send();
            } else {
                res.status(404).json({ error: 'Todo not found' });
            }
        } catch (error) {
            console.error('Error in delete:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    _logOperation(opName, username, todoId) {
        this._tracer.scoped(() => {
            const traceId = this._tracer.id;
            this._redisClient.publish(this._logChannel, JSON.stringify({
                zipkinSpan: traceId,
                opName: opName,
                username: username,
                todoId: todoId,
            }));
        });
    }

    async _getTodoData(userID) {
        const cacheKey = `todo:${userID}`;
        
        try {
            // Cache Aside Pattern: Try to get from Redis first
            const cachedData = await this._redisClient.get(cacheKey);
            
            if (cachedData) {
                // Cache HIT - return cached data
                console.log(`✅ Cache HIT for user: ${userID}`);
                return JSON.parse(cachedData);
            }
            
            // Cache MISS - create default data
            console.log(`❌ Cache MISS for user: ${userID}`);
            const data = {
                items: {
                    '1': {
                        id: 1,
                        content: "Create new todo",
                    },
                    '2': {
                        id: 2,
                        content: "Update me",
                    },
                    '3': {
                        id: 3,
                        content: "Delete example ones",
                    }
                },
                lastInsertedID: 3
            };

            // Cache Aside: Store in Redis with TTL
            await this._redisClient.setEx(cacheKey, this._cacheTTL.todoData, JSON.stringify(data));
            console.log(`💾 Cache STORED for user: ${userID} with TTL: ${this._cacheTTL.todoData}s`);
            
            return data;
            
        } catch (error) {
            console.error('Redis error in _getTodoData:', error);
            
            // Fallback: return default data without caching
            console.log(`⚠️ Fallback mode for user: ${userID}`);
            return {
                items: {
                    '1': { id: 1, content: "Create new todo" },
                    '2': { id: 2, content: "Update me" },
                    '3': { id: 3, content: "Delete example ones" }
                },
                lastInsertedID: 3
            };
        }
    }

    async _setTodoData(userID, data) {
        const cacheKey = `todo:${userID}`;
        
        try {
            // Cache Aside: Update Redis cache
            await this._redisClient.setEx(cacheKey, this._cacheTTL.todoData, JSON.stringify(data));
            console.log(`💾 Cache UPDATED for user: ${userID} with TTL: ${this._cacheTTL.todoData}s`);
        } catch (error) {
            console.error('Redis error in _setTodoData:', error);
            // Continue without caching - don't fail the operation
        }
    }
}

module.exports = TodoController;