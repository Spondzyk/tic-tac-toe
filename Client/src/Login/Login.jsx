import React, { useState } from "react";
import { authenticate } from "../authentication.service.js";
import './Login.css';

export const Login = ({ setLoggedIn, onFormSwitch }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        authenticate(username, password)
            .then((data) => {
                console.log(data);
                localStorage.setItem('token', data.accessToken.jwtToken);
                setLoggedIn(true);
            })
            .catch((err) => {
                console.log(err);
            });
    };

    return (
        <div className="auth-form-container">
            <h2>Login</h2>
            <form className="login-form" onSubmit={handleSubmit}>
                <label htmlFor="username">Username</label>
                <input
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    placeholder="username"
                    id="username"
                    name="username"
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
                <button type="submit">Log In</button>
            </form>
            <button className="link-btn" onClick={() => onFormSwitch('register')}>
                Don't have an account? Register here.
            </button>
        </div>
    );
};
