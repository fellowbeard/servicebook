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

  function handleChange(event) {
    setResource({
      ...resource,
      [event.target.name]: event.target.value,
    });
  }

  function handleSubmit(event) {
    event.preventDefault();

    const url = isEditing ? `/api/v1/resources/${existingResource.id}` : "api/v1/resources";

    const method = isEditing ? "PATCH" : "POST";

    fetch(url, {
      method,
      headers: authHeaders(),
      body: JSON.stringify({
        resource,
      }),
    })
      .then((res) => res.json())
      .then((savedResource) => {
        if (isEditing) {
          onResourceUpdated?.(savedResource);
        } else {
          onResourceCreated?.(savedResource);
          setResource(blankResource);
        }
      });
  }

  function handleDelete() {
    if (!existingResource) return;

    fetch(`api/v1/resources/${existingResource.id}`, {
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

      <button type="submit">{isEditing ? "Update Resource" : "Save Resource"}</button>

      {isEditing && (
        <button type="button" onClick={handleDelete}>
          Delete Resource
        </button>
      )}
    </form>
  );
}
