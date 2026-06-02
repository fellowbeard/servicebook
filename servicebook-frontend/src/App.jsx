import './App.css'
import { Routes, Route, Link } from 'react-router-dom'
import { useState } from 'react'

import UserDashboard from './components/UserDashboard.jsx'
import Login from './components/Login.jsx'
import ClientCard from './components/ClientCard.jsx'

function App() {
  const [currentUser, setCurrentUser] = useState(null)

  return (
    <>
      <nav>
        <Link to="/">Login</Link> |{' '}
        <Link to="/userdashboard">Dashboard</Link>
      </nav>

      <Routes>
        <Route
          path="/"
          element={<Login setCurrentUser={setCurrentUser} />}
        />

        <Route
          path="/userdashboard"
          element={
            currentUser ? (
              <UserDashboard currentUser={currentUser} />
            ) : (
              <p>LOGIN You dork</p>
            )
          }
        />
        <Route
          path="/clients/:id"
          element={
            currentUser ? (
              <ClientCard currentUser={currentUser} />
            ) : (
              <p>Please log in first.</p>
            )
          }
        />
      </Routes>
    </>
  )
}

export default App