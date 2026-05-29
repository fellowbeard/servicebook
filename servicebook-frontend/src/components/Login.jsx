import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function Login({ setCurrentUser }) {
  const [email, setEmail] = useState('')
  const [error, setError] = useState(null)
  const navigate = useNavigate()

  function handleSubmit(event) {
    event.preventDefault()

    fetch(`/api/v1/users`)
      .then((res) => res.json())
      .then((users) => {
        const foundUser = users.find((user) => user.email === email)

        if (!foundUser) {
          setError('No user with that email bruh')
          return
        }

        setCurrentUser(foundUser)
        navigate('/userdashboard')
      })
      .catch((err) => setError(err.message || 'Fetch error'))
  }

  return (
    <main>
      <h2>Log In</h2>
      <form onSubmit={handleSubmit}>
        <label htmlFor="email">Email</label>

        <input
          id="email"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
        />

        <button type="submit">Log in</button>
      </form>

      {error && <p>{error}</p>}
    </main>
  )
}