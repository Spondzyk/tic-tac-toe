import React, { useState } from "react";
import { CognitoUserAttribute } from 'amazon-cognito-identity-js';
import userpool from '../aws-exports.js';
import './Register.css';

export const Register = ({ onFormSwitch }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [username, setUsername] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        const attributeList = [];
        attributeList.push(
            new CognitoUserAttribute({
                Name: 'email',
                Value: email,
            }),
        );
        userpool.signUp(username, password, attributeList, null, (err, data) => {
            if (err) {
                console.log(err);
                alert("Couldn't sign up");
            } else {
                console.log(data);
                alert('User Added Successfully! You can now log in.');
            }
        });
    };

    return (
        <div className="auth-form-container">
            <h2>Register</h2>
            <form className="register-form" onSubmit={handleSubmit}>
                <label htmlFor="username">Username</label>
                <input
                    value={username}
                    name="username"
                    onChange={(e) => setUsername(e.target.value)}
                    id="username"
                    placeholder="username"
                />
                <label htmlFor="email">Email</label>
                <input
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    type="email"
                    placeholder="youremail@gmail.com"
                    id="email"
                    name="email"
                />
                <label htmlFor="password">Password</label>
                <input
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    type="password"
                    placeholder="********"
                    id="password"
                    name="password"
                />
                <button type="submit">Sign Up</button>
            </form>
            <button className="link-btn" onClick={() => onFormSwitch('login')}>
                Already have an account? Login here.
            </button>
        </div>
    );
};
