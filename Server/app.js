const { createServer } = require("http");
const { Server } = require("socket.io");
const {saveGameResult} = require("./database_connection");
const jwkToPem = require('jwk-to-pem');
const jsonwebtoken = require('jsonwebtoken');

const server_address = "http://" + process.env.FRONTEND_GLOBAL_IP + ":8080"
const httpServer = createServer();
const io = new Server(httpServer, {
  cors: server_address,
});

const allUsers = {};
const allRooms = [];

let isValid = false;

const jsonWebKeys = [
  {
    "alg": "RS256",
    "e": "AQAB",
    "kid": "E0eA/upedKgiHiTkkDcpWIaEqR1FE0ZCmwmo+mRx/jg=",
    "kty": "RSA",
    "n": "2Te-Mkebq0rxc-VFa7CgxD7ZjAMUayd2tpJBxGWcErSShGqPC6BRvxncMW_5GSaupQlbmmJxwqiDvGezfaoSaVQF5sVbXyMYtuqA3uQ4Uu7U2b1k0JK5-kAiNHAXt63beHVOcu42KehwGmVL1sxoBDPT_hitpe8rKRKTs9d3OXyXVmA_KTQuZyxbO9WInRJck66nYo_Ym8XuQNpVE-fPKsGX4X_0R6hIXnGYF8W3NzAUZhk14uX5JfHCeDNbuZiKUS0uLsFU98fC0DUhOSrxN-g_VFnA1gBdJhaLkPsGxKE9nntJG7UFUcYnyFns0s3W3YrYgJKr_mPpN3wrs57zAw",
    "use": "sig"
  }, {
    "alg": "RS256",
    "e": "AQAB",
    "kid": "UdPsVYDEkX45+DRnisZZ4yoeoMPp+pKhuIlI/CUXXF4=",
    "kty": "RSA",
    "n": "yykFsr6_xmdItmyz_byMncCrqHYfyNyf5aUff2O72tD_uYfdgB91TEdrvaaDZS5wkTt7kkZyMIDJwTQXwhk8RdPquw_FdsFp5iVbcBYFkT6sUMthj6KtrJ56NjGLjiGycnhwQ0j-Rqh1SOyF3la2RDseMWN0QSm6bfleqLpqe2sIq7Yc23llihW_5Mdi_DhYvxRLLhfSpYozNtCBQVgWDCiNo7ZlT31iLG2GLqUdPZtbwx86mVJrifB_klpF8iM5FHf-VvbfETpRzxe05kJke8Fsrg8wBdR_5z_BBLnPpA66bcQ-vPpK23xy7VfEqntZv7PhgzmtnVY8YF1q-nAG0w",
    "use": "sig"
  }
]

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
    console.log(data);

    saveGameResult(data.player1, data.player2, data.winner);
  });
});

httpServer.listen(3000);
