import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { setToken } from "../utils/auth.js";
import { parseApiResponse } from "../utils/api.js";

export default function Login({ setCurrentUser }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  function handleSubmit(event) {
    event.preventDefault();

    fetch("/api/v1/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email,
        password,
      }),
    })
      .then(parseApiResponse)
      .then(({ ok, data, error }) => {
        if (!ok) throw new Error(error.message);
        setToken(data.token);
        setCurrentUser(data.user);
        navigate("/userdashboard");
      })
      .catch((err) => {
        setError(err.message);
      });
  }

  return (
    <main>
      <h2>Log In</h2>
      <form onSubmit={handleSubmit}>
        <label htmlFor="email">Email</label>

        <input id="email" type="email" value={email} onChange={(event) => setEmail(event.target.value)} />
        <input id="password" type="password" value={password} onChange={(event) => setPassword(event.target.value)} />

        <button type="submit">Log in</button>
      </form>

      {error && <p>{error}</p>}
    </main>
  );
}
