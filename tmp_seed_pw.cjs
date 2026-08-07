const { DatabaseSync } = require('node:sqlite');
const { randomUUID } = require('crypto');
const db = new DatabaseSync('hr-app.db');
const now = new Date().toISOString();
db.prepare('insert into hr_app_Passwords (ID, authorizationPerson, password, authorizationLevel, createdAt, modifiedAt) values (?, ?, ?, ?, ?, ?)').run(randomUUID(), 'calisan', '2', 'calisan', now, now);
console.log('inserted');
