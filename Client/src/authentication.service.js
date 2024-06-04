import {AuthenticationDetails, CognitoUser, CognitoRefreshToken, CognitoUserPool} from 'amazon-cognito-identity-js';

const userPool = new CognitoUserPool({
    UserPoolId: "us-east-1_CYb1TNMq6",
    ClientId: "5vb4uuqccg8d8e6hb6nich39ec",
})

export const authenticate=(Username,Password)=>{
    return new Promise((resolve,reject)=>{
        const user= new CognitoUser({
            Username:Username,
            Pool: userPool
        });

        const authDetails= new AuthenticationDetails({
            Username:Username,
            Password:Password
        });

        user.authenticateUser(authDetails,{
            onSuccess:(result)=>{
                console.log("login successful");
                resolve(result);
            },
            onFailure:(err)=>{
                console.log("login failed",err);
                reject(err);
            }
        });
    });
};

export const logout = () => {
    userPool.getCurrentUser().signOut();
    window.location.href = '/';
};

export const getNick = () => {
    return userPool.getCurrentUser().getUsername();
}

export const refreshSession = () => {
    const cognitoUser = userPool.getCurrentUser();

    const refreshToken = new CognitoRefreshToken({ RefreshToken: localStorage.getItem('refresh')})

    cognitoUser.getSession(function(err, session) {
        localStorage.setItem('token', session.accessToken.jwtToken);
        if (err) {
            console.log(err);
        }
        else {
            if (!session.isValid()) {
                cognitoUser.refreshSession(refreshToken, (err, session) => {
                    if (err) {
                        console.log('In the err' + err);
                    }
                    else {
                        localStorage.setItem('token', session.accessToken.jwtToken);
                    }
                });
            }
        }
    });
}