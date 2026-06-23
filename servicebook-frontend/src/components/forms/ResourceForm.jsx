import { useState } from "react";
import { authHeaders } from "../../utils/auth";

export default function ResourceForm({
  existingResource = null,
  onResourceCreated,
  onResourceUpdated,
  onResourceDeleted,
}) {
  const isEditing = Boolean(existingResource);

  const blankResource = {
    name: "",
  };

  const [resource, setResource] = useState({
    name: existingResource?.name || "",
  });

  const [error, setError] = useState("");

  function handleChange(event) {
    setResource({
      ...resource,
      [event.target.name]: event.target.value,
    });

    setError("");
  }

  function handleSubmit(event) {
    event.preventDefault();
    setError("");

    const url = isEditing ? `/api/v1/resources/${existingResource.id}` : "/api/v1/resources";

    const method = isEditing ? "PATCH" : "POST";

    fetch(url, {
      method,
      headers: authHeaders(),
      body: JSON.stringify({
        resource,
      }),
    })
      .then((res) => {
        return res.json().then((data) => ({
          ok: res.ok,
          data,
        }));
      })
      .then(({ ok, data }) => {
        if (!ok) {
          setError(data.errors?.join(", ") || "Resource could not be saved.");
          return;
        }

        if (isEditing) {
          onResourceUpdated?.(data);
        } else {
          onResourceCreated?.(data);
          setResource(blankResource);
        }
      });
  }

  function handleDelete() {
    if (!existingResource) return;

    fetch(`/api/v1/resources/${existingResource.id}`, {
      method: "DELETE",
      headers: authHeaders(),
    }).then(() => {
      onResourceDeleted?.(existingResource.id);
      setResource(blankResource);
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      <h3>{isEditing ? "Edit resource" : "New Resource"}</h3>

      <label htmlFor="resource-name">Resource Name</label>
      <input
        id="resource-name"
        name="name"
        value={resource.name}
        onChange={handleChange}
        placeholder="Chair 1, Room A, Booth 2"
      />

      {error && <p className="error">{error}</p>}

      <button type="submit">{isEditing ? "Update Resource" : "Save Resource"}</button>

      {isEditing && (
        <button type="button" onClick={handleDelete}>
          Delete Resource
        </button>
      )}
    </form>
  );
}
