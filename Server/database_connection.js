const mysql = require('mysql');

// MySQL connection configuration
const connectionConfig = {
    host: 'tic-tac-toe.c5nh2lwhprzv.us-east-1.rds.amazonaws.com',
    user: 'root',
    database: 'tic-tac-toe',
    password: 'Mikolaj123',
    port: 3306,
};

const createTableQuery = `
                CREATE TABLE IF NOT EXISTS GameResults (
                    GameID INT AUTO_INCREMENT PRIMARY KEY,
                    Player1 VARCHAR(255),
                    Player2 VARCHAR(255),
                    Winner VARCHAR(255)
                );
            `;

const insertQuery = `
            INSERT INTO GameResults (Player1, Player2, Winner)
            VALUES (?, ?, ?)
        `;

const handleDatabaseOperation = async (player1, player2, winner) => {
    let connection;
    try {
        console.log('Attempting to connect to the database...');
        connection = await mysql.createConnection(connectionConfig);
        console.log('Connected to the database successfully');

        // Create the table if it doesn't exist
        await connection.query(createTableQuery);
        console.log('Table created successfully');

        // Save the game result
        const values = [player1, player2, winner];
        connection.query(insertQuery, values, (err, results) => {
            if (err) {
                console.error('Error saving game result:', err.stack);
                return;
            }
            console.log('Game result saved successfully');
        });
    } catch (error) {
        console.error('Error during database operation:', error);
    } finally {
        if (connection) {
            await connection.end();
            console.log('Database connection closed');
        }
    }
};

module.exports = {
    handleDatabaseOperation
};
