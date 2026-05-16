'use client'

import { useRouter } from 'next/navigation'
import { useState } from 'react'

export function TrackingForm() {
  const router = useRouter()
  const [code, setCode] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const trimmed = code.trim()
    if (!trimmed) {
      setError('Masukkan nomor resi atau kode tracking')
      return
    }
    setError('')
    setLoading(true)
    router.push(`/tracking/${encodeURIComponent(trimmed)}`)
  }

  return (
    <form onSubmit={handleSubmit} className="flex w-full flex-col gap-3">
      <div className="flex gap-3">
        <input
          id="tracking-code-input"
          value={code}
          onChange={(e) => setCode(e.target.value)}
          placeholder="Masukkan nomor resi atau kode RSQ-..."
          className="h-12 flex-1 rounded-4xl border border-[#edebe9] bg-[#f9f9f9] px-5 text-sm font-medium text-[rgba(0,0,0,0.87)] outline-none transition-all duration-200 placeholder:text-[rgba(0,0,0,0.38)] focus:border-primary focus:ring-2 focus:ring-[#d4e9e2]"
          aria-label="Nomor resi atau kode tracking"
          disabled={loading}
        />
        <button
          type="submit"
          className="h-12 rounded-4xl border border-primary bg-primary px-6 text-sm font-semibold text-white transition-all duration-200 hover:bg-accent hover:border-accent active:scale-95 disabled:opacity-60"
          disabled={loading}
        >
          {loading ? (
            <span className="flex items-center gap-2">
              <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
              Mencari
            </span>
          ) : (
            'Lacak'
          )}
        </button>
      </div>
      {error && (
        <p className="text-xs font-medium text-destructive" role="alert">
          {error}
        </p>
      )}
    </form>
  )
}
