import React, { useState } from 'react';
import { Login } from "../Login/Login.jsx";
import { Register } from "../Register/Register.jsx";
import './AuthPage.css';

const AuthPage = ({ setLoggedIn }) => {
    const [currentForm, setCurrentForm] = useState('login');

    const toggleForm = (formName) => {
        setCurrentForm(formName);
    };

    return (
        <div className='Login'>
            {currentForm === 'login' ? (
                <Login setLoggedIn={setLoggedIn} onFormSwitch={toggleForm} />
            ) : (
                <Register onFormSwitch={toggleForm} />
            )}
        </div>
    );
};

export default AuthPage;
