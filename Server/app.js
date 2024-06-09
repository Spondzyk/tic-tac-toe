const { createServer } = require("http");
const { Server } = require("socket.io");
const {handleDatabaseOperation} = require("./database_connection");
const jwkToPem = require('jwk-to-pem');
const jsonwebtoken = require('jsonwebtoken');
const jsonWebKeys = require('./aws_keys');

const server_address = process.env.FRONTEND_URL + ":8080"
const httpServer = createServer();
const io = new Server(httpServer, {
  cors: server_address,
});

const allUsers = {};
const allRooms = [];

let isValid = false;

function decodeTokenHeader(token) {
  const [headerEncoded] = token.split('.');
  const buff = new Buffer(headerEncoded, 'base64');
  const text = buff.toString('ascii');
  return JSON.parse(text);
}

function getJsonWebKeyWithKID(kid) {
  for (let jwk of jsonWebKeys) {
    if (jwk.kid === kid) {
      return jwk;
    }
  }
  return null
}

function verifyJsonWebTokenSignature(token, jsonWebKey, clbk) {
  const pem = jwkToPem(jsonWebKey);
  jsonwebtoken.verify(token, pem, {algorithms: ['RS256']}, (err, decodedToken) => clbk(err, decodedToken))
}

function validateToken(token) {
  const header = decodeTokenHeader(token);
  const jsonWebKey = getJsonWebKeyWithKID(header.kid);
  verifyJsonWebTokenSignature(token, jsonWebKey, (err, decodedToken) => {
    if (err) {
      console.log(err);
    } else {
      console.log(decodedToken);
      isValid = true;
    }
  })
}

io.on("connection", (socket) => {
  allUsers[socket.id] = {
    socket: socket,
    online: true,
    playing: false,
  };

  isValid = false;
  const headers = socket.handshake.headers;

  const token = headers.token;

  validateToken(token)

  if (!isValid) {
    socket.disconnect();
    return;
  }

  socket.on("request_to_play", (data) => {
    const currentUser = allUsers[socket.id];
    currentUser.playerName = data.playerName;

    let opponentPlayer;

    for (const key in allUsers) {
      const user = allUsers[key];
      if (user.online && !user.playing && socket.id !== key) {
        opponentPlayer = user;
        break;
      }
    }

    if (opponentPlayer) {
      currentUser.playing = true;
      opponentPlayer.playing = true;

      allRooms.push({
        player1: opponentPlayer,
        player2: currentUser,
      });

      currentUser.socket.emit("OpponentFound", {
        opponentName: opponentPlayer.playerName,
        playingAs: "circle",
      });

      opponentPlayer.socket.emit("OpponentFound", {
        opponentName: currentUser.playerName,
        playingAs: "cross",
      });

      currentUser.socket.on("playerMoveFromClient", (data) => {
        opponentPlayer.socket.emit("playerMoveFromServer", {
          ...data,
        });
      });

      opponentPlayer.socket.on("playerMoveFromClient", (data) => {
        currentUser.socket.emit("playerMoveFromServer", {
          ...data,
        });
      });
    } else {
      currentUser.socket.emit("OpponentNotFound");
    }
  });

  socket.on("disconnect", function () {
    const currentUser = allUsers[socket.id];
    currentUser.online = false;
    currentUser.playing = false;

    for (let index = 0; index < allRooms.length; index++) {
      const {player1, player2} = allRooms[index];

      if (player1.socket.id === socket.id) {
        player2.socket.emit("opponentLeftMatch");
        allRooms.splice(index, 1); // Remove the room from allRooms array
        break;
      }

      if (player2.socket.id === socket.id) {
        player1.socket.emit("opponentLeftMatch");
        allRooms.splice(index, 1); // Remove the room from allRooms array
        break;
      }
    }
  });

  socket.on("end_game", (data) => {
    handleDatabaseOperation(data.player1, data.player2, data.winner).then(r => console.log(data));
  });
});

httpServer.listen(3000);
