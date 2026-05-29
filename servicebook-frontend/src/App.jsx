import './App.css'
import { Routes, Route, Link } from 'react-router-dom'
import UserDashboard from './components/UserDashboard.jsx'

function App() {
  return (
    <>
      <nav>
        <Link to="/">Login</Link> |{' '}
        <Link to="/userdashboard">Dashboard</Link>
      </nav>

      <Routes>
        <Route path="/" element={<h1>Service Book</h1>} />

        <Route
          path="/userdashboard"
          element={
            <UserDashboard
              apiBase="http://localhost:3000/api/v1"
              userId={5}
            />
          }
        />
      </Routes>
    </>
  )
}

export default App