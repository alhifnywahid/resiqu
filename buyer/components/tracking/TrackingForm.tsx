'use client'

import { useRouter } from 'next/navigation'
import { useState } from 'react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

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
      <div className="flex gap-2">
        <Input
          id="tracking-code-input"
          value={code}
          onChange={(e: React.ChangeEvent<HTMLInputElement>) => setCode(e.target.value)}
          placeholder="Masukkan nomor resi atau kode RSQ-..."
          className="h-10 flex-1 text-sm bg-white dark:bg-slate-900"
          aria-label="Nomor resi atau kode tracking"
          disabled={loading}
        />
        <Button
          type="submit"
          className="h-10 px-4 bg-blue-600 hover:bg-blue-700 text-white"
          disabled={loading}
        >
          {loading ? (
            <span className="flex items-center gap-2 text-sm">
              <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
              Mencari
            </span>
          ) : (
            'Lacak'
          )}
        </Button>
      </div>
      {error && (
        <p className="text-xs text-red-500" role="alert">
          {error}
        </p>
      )}
    </form>
  )
}
