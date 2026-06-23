import { useState } from "react";
import { authHeaders } from "../../utils/auth.js";
import { parseApiResponse, extractFieldErrors } from "../../utils/api";

export default function ServiceForm({ existingService = null, onServiceCreated, onServiceUpdated, onServiceDeleted }) {
  const isEditing = Boolean(existingService);

  const blankService = {
    title: "",
    description: "",
    duration_minutes: "",
    price: "",
  };

  const [service, setService] = useState({
    title: existingService?.title || "",
    description: existingService?.description || "",
    duration_minutes: existingService?.duration_minutes || "",
    price: existingService?.price || "",
  });

  function handleChange(event) {
    setService({
      ...service,
      [event.target.name]: event.target.value,
    });
  }

  const [error, setError] = useState(null);

  function handleSubmit(event) {
    event.preventDefault();
    setError(null);

    const url = isEditing ? `/api/v1/services/${existingService.id}` : "/api/v1/services";

    const method = isEditing ? "PATCH" : "POST";

    fetch(url, {
      method,
      headers: authHeaders(),
      body: JSON.stringify({
        service: {
          ...service,
        },
      }),
    })
      .then(parseApiResponse)
      .then(({ ok, data, error: apiError }) => {
        if (!ok) {
          const fieldErrors = extractFieldErrors(apiError.details);
          setError(fieldErrors ? Object.values(fieldErrors).flat().join(', ') : apiError.message);
          return;
        }

        if (isEditing) {
          onServiceUpdated?.(data);
        } else {
          onServiceCreated?.(data);
          setService(blankService);
        }
      });
  }

  function handleDelete() {
    if (!existingService) return;

    fetch(`/api/v1/services/${existingService.id}`, {
      method: "DELETE",
      headers: authHeaders(),
    }).then(() => {
      onServiceDeleted?.(existingService.id);
      setService(blankService);
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      <h3>{isEditing ? "Edit Service" : "New Service"}</h3>

      <label htmlFor="service-title">Service Name</label>
      <input id="service-title" name="title" value={service.title} onChange={handleChange} />

      <label htmlFor="service-description">Description</label>
      <textarea id="service-description" name="description" value={service.description} onChange={handleChange} />

      <label htmlFor="service-duration">Duration in Minutes</label>
      <input
        id="service-duration"
        name="duration_minutes"
        type="number"
        value={service.duration_minutes}
        onChange={handleChange}
      />

      <label htmlFor="service-price">Price</label>
      <input id="service-price" name="price" type="number" step="0.01" value={service.price} onChange={handleChange} />

      <button type="submit">{isEditing ? "Update Service" : "Save Service"}</button>

      {isEditing && (
        <button type="button" onClick={handleDelete}>
          Delete Service
        </button>
      )}
    </form>
  );
}
