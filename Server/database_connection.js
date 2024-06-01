const { v4: uuidv4 } = require('uuid');
const AWS = require('aws-sdk');

AWS.config.update({
    region: 'us-east-1',
    accessKeyId: 'YOUR_ACCESS_KEY_ID',
    secretAccessKey: 'YOUR_SECRET_ACCESS_KEY'
});

const dynamoDB = new AWS.DynamoDB();
const docClient = new AWS.DynamoDB.DocumentClient();

const createTableParams = {
    TableName: 'GameResults',
    AttributeDefinitions: [
        { AttributeName: 'GameID', AttributeType: 'N' }
    ],

    KeySchema: [
        { AttributeName: 'GameID', KeyType: 'HASH' }
    ],
    ProvisionedThroughput: {
        ReadCapacityUnits: 1,
        WriteCapacityUnits: 1
    }
};

dynamoDB.createTable(createTableParams, (err, data) => {
    if (err) {
        console.error('Error creating table:', err);
    } else {
        console.log('Table created successfully');
    }
});

const saveGameResult = (player1, player2, winner) => {
    const params = {
        TableName: 'GameResults',
        Item: {
            'GameID': uuidv4(undefined, undefined, undefined),
            'Player1': player1,
            'Player2': player2,
            'Winner': winner
        }
    };

    docClient.put(params, (err, data) => {
        if (err) {
            console.error('Error saving game result:', err);
        } else {
            console.log('Game result saved successfully');
        }
    });
};

module.exports = {
    saveGameResult
};
