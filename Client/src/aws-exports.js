import { CognitoUserPool } from 'amazon-cognito-identity-js';

const poolData = {
    UserPoolId: "us-east-1_CYb1TNMq6",
    ClientId: "5vb4uuqccg8d8e6hb6nich39ec",
};
export default new CognitoUserPool(poolData);
