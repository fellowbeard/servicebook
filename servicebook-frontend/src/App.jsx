import './App.css'
import { Routes, Route, Link } from 'react-router-dom'
import { useState } from 'react'

import UserDashboard from './components/UserDashboard.jsx'
import Login from './components/Login.jsx'

function App() {
  const [currentUser, setCurrentUser] = useState({ id: 5 }) // id hardcoded for testing

  return (
    <>
      <nav>
        <Link to="/">Login</Link> |{' '}
        <Link to="/userdashboard">Dashboard</Link>
      </nav>

      <Routes>
        <Route path="/"
          element={
            <Login
              setCurrentUser={setCurrentUser}
            />
          }
        />

        <Route
          path="/userdashboard"
          element={
            currentUser ? (
              <UserDashboard
                apiBase="/api/v1"
                userId={currentUser.id}
              />
            ) : (
              <p> LOGIN You dork </p>
            )
          }
        />
      </Routes>
    </>
  )
}

export default App