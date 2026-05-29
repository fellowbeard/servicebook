import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom' // optional; remove if not using react-router

export default function UserDashboard({ apiBase = '/api/v1', userId }) {
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [user, setUser] = useState(null)
  const [stats, setStats] = useState({ clients: 0, services: 0, appointments: 0 })
  const [recentAppointments, setRecentAppointments] = useState([])
  const [recentClients, setRecentClients] = useState([])

  useEffect(() => {
    const controller = new AbortController()
    async function load() {
      setLoading(true)
      setError(null)
      try {
        if (userId) {
          const res = await fetch(`${apiBase}/users/${userId}/dashboard`, { signal: controller.signal })
          if (!res.ok) throw new Error('Failed to load dashboard')
          const payload = await res.json()
          setUser(payload.user || null)
          setStats({
            clients: payload.clients_count ?? 0,
            services: payload.services_count ?? 0,
            appointments: payload.appointments_count ?? 0,
          })
          setRecentClients(payload.recent_clients || [])
          setRecentAppointments(payload.recent_appointments || [])
        } else {
          // fallback to generic endpoints when no userId is provided
          const [meRes, apptsRes, clientsRes] = await Promise.all([
            fetch(`${apiBase}/me`, { signal: controller.signal }).catch(() => ({ ok: false })),
            fetch(`${apiBase}/appointments?recent=true&limit=5`, { signal: controller.signal }).catch(() => ({ ok: false })),
            fetch(`${apiBase}/clients?recent=true&limit=5`, { signal: controller.signal }).catch(() => ({ ok: false })),
          ])

          if (meRes && meRes.ok) setUser(await meRes.json())
          if (apptsRes && apptsRes.ok) setRecentAppointments(await apptsRes.json())
          if (clientsRes && clientsRes.ok) setRecentClients(await clientsRes.json())
          setStats(prev => ({ ...prev, appointments: recentAppointments.length, clients: recentClients.length }))
        }
      } catch (err) {
        if (err.name !== 'AbortError') setError(err.message || 'Unknown error')
      } finally {
        setLoading(false)
      }
    }
    load()
    return () => controller.abort()
  }, [apiBase, userId])

  if (loading) return <div aria-live="polite">Loading dashboard…</div>
  if (error) return <div role="alert">Error: {error}</div>

  return (
    <main className="user-dashboard">
      <header className="dashboard-header">
        <h1>Welcome{user?.name ? `, ${user.name}` : ''}</h1>
        <p className="muted">{user?.email}</p>
      </header>

      <section className="dashboard-stats" aria-label="Key stats">
        <div className="stat">
          <strong>{stats.clients}</strong>
          <span>Clients</span>
        </div>
        <div className="stat">
          <strong>{stats.services}</strong>
          <span>Services</span>
        </div>
        <div className="stat">
          <strong>{stats.appointments}</strong>
          <span>Appointments</span>
        </div>
      </section>

      <section className="dashboard-quick-actions">
        <h2>Quick actions</h2>
        <div>
          <Link to="/clients/new">New client</Link>{' • '}
          <Link to="/appointments/new">New appointment</Link>
        </div>
      </section>

      <section className="dashboard-recent">
        <div>
          <h3>Recent appointments</h3>
          <ul>
            {recentAppointments.length === 0 && <li>No recent appointments</li>}
            {recentAppointments.map(a => (
              <li key={a.id}>
                <Link to={`/appointments/${a.id}`}>{a.title ?? `#${a.id}`}</Link>
                <small className="muted"> — {a.scheduled_at}</small>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h3>Recent clients</h3>
          <ul>
            {recentClients.length === 0 && <li>No recent clients</li>}
            {recentClients.map(c => (
              <li key={c.id}>
                <Link to={`/clients/${c.id}`}>{c.name ?? c.email}</Link>
              </li>
            ))}
          </ul>
        </div>
      </section>
    </main>
  )
}

