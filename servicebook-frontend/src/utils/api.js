export async function parseApiResponse(res) {
  let data = null;
  try {
    data = await res.json();
  } catch (err) {
    // Non-JSON responses
    return {
      ok: res.ok,
      data: null,
      error: { message: res.statusText || 'Request failed' },
    };
  }

  if (res.ok) {
    return { ok: true, data, error: null };
  }

  // Try known shapes: { error: { message, details } } or { errors: [..] }
  let message = 'Request failed';
  let details = null;

  if (data) {
    if (data.error) {
      message = data.error.message || String(data.error);
      details = data.error.details;
    } else if (data.errors) {
      message = Array.isArray(data.errors) ? data.errors.join(', ') : String(data.errors);
    } else if (typeof data === 'string') {
      message = data;
    }
  }

  return {
    ok: false,
    data,
    error: {
      message,
      details,
    },
  };
}

export function extractFieldErrors(details) {
  // details is expected to be an object of arrays: { field: ['msg1', 'msg2'] }
  if (!details || typeof details !== 'object') return null;
  const fieldErrors = {};
  Object.entries(details).forEach(([field, val]) => {
    if (Array.isArray(val)) fieldErrors[field] = val;
    else if (typeof val === 'string') fieldErrors[field] = [val];
    else fieldErrors[field] = [String(val)];
  });
  return fieldErrors;
}
