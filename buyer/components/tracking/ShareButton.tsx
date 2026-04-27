'use client'

import { useState } from 'react'

import { Button } from '@/components/ui/button'

export function ShareButton({ code }: { code: string }) {
  const [copied, setCopied] = useState(false)

  async function handleShare() {
    const url = `${window.location.origin}/tracking/${encodeURIComponent(code)}`

    if (navigator.share) {
      try {
        await navigator.share({
          title: `Tracking Paket ${code}`,
          text: `Lacak status paket ${code} di Resiqu`,
          url,
        })
      } catch {
        // user cancelled, ignore
      }
    } else {
      await navigator.clipboard.writeText(url)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  return (
    <Button variant="outline" size="sm" onClick={handleShare}>
      {copied ? (
        <span className="flex items-center gap-1.5">
          <span>✓</span> Link disalin!
        </span>
      ) : (
        <span className="flex items-center gap-1.5">
          <span>🔗</span> Bagikan
        </span>
      )}
    </Button>
  )
}
