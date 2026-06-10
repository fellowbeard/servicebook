import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function NewClient({ currentUser }) {
  const navigate = useNavigate();

  const [client, setClient] = useState({
    first_name: "",
    last_name: "",
    email: "",
    phone: "",
  });

  function handleChange(event) {
    setClient({
      ...client,
      [event.target.name]: event.target.value,
    });
  }

  function handleSubmit(event) {
    event.preventDefault();

    fetch("/api/v1/clients", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        client: {
          ...client,
          user_id: currentUser.id,
        },
      }),
    })
      .then((res) => res.json())
      .then((createdClient) => {
        navigate(`/clients/${createdClient.id}`);
      });
  }

  return (
    <main>
      <h1>New Client</h1>

      <form onSubmit={handleSubmit}>
        <label htmlFor="first_name">First Name</label>
        <input id="first_name" name="first_name" value={client.first_name} onChange={handleChange} />

        <label htmlFor="last_name">Last Name</label>
        <input id="last_name" name="last_name" value={client.last_name} onChange={handleChange} />

        <label htmlFor="email">Email</label>
        <input id="email" name="email" type="email" value={client.email} onChange={handleChange} />

        <label htmlFor="phone">Phone</label>
        <input id="phone" name="phone" value={client.phone} onChange={handleChange} />

        <button type="submit">Create Client</button>
      </form>
    </main>
  );
}
