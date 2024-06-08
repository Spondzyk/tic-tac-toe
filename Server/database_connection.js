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

const checkTableExistsQuery = `
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = 'tic-tac-toe'
      AND table_name = 'GameResults';
`;

const query = (connection, sql, values = []) => {
    return new Promise((resolve, reject) => {
        connection.query(sql, values, (err, results) => {
            if (err) {
                reject(err);
            } else {
                resolve(results);
            }
        });
    });
};

const handleDatabaseOperation = async (player1, player2, winner) => {
    const connection = mysql.createConnection(connectionConfig);

    try {
        console.log('Attempting to connect to the database...');
        await query(connection, 'SELECT 1'); // Test connection
        console.log('Connected to the database successfully');

        // Check if the table exists
        const results = await query(connection, checkTableExistsQuery);
        const tableExists = results[0].count > 0;

        if (!tableExists) {
            console.log('Table does not exist. Creating table...');
            await query(connection, createTableQuery);
            console.log('Table created successfully');
        } else {
            console.log('Table already exists. Skipping creation.');
        }

        // Save the game result
        const values = [player1, player2, winner];
        await query(connection, insertQuery, values);
        console.log('Game result saved successfully');

    } catch (error) {
        console.error('Error during database operation:', error);
    } finally {
        connection.end();
        console.log('Database connection closed');
    }
};

module.exports = {
    handleDatabaseOperation
};
