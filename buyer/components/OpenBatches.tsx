'use client'

import { useOpenBatches } from '@/hooks/use-open-batches'

export function OpenBatches() {
  const { batches, loading, now } = useOpenBatches()

  if (loading) {
    return (
      <div className="flex justify-center p-8">
        <div className="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent" />
      </div>
    )
  }

  if (batches.length === 0) {
    return (
      <div className="mt-8 text-center rounded-xl bg-white p-6 shadow-[0px_0px_0.5px_0px_rgba(0,0,0,0.14),0px_1px_1px_0px_rgba(0,0,0,0.24)]">
        <svg className="w-8 h-8 mx-auto mb-3 text-[#2b5148]" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5m8.25 3v6.75m0 0l-3-3m3 3l3-3M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z" />
        </svg>
        <h3 className="text-sm font-semibold text-[rgba(0,0,0,0.87)]">Belum Ada Kontainer</h3>
        <p className="text-xs mt-1 text-muted-foreground">Saat ini belum ada jadwal transit kontainer yang tersedia.</p>
      </div>
    )
  }

  return (
    <div className="mt-8 space-y-4">
      <div className="flex items-center gap-2 mb-4">
        <svg className="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z" />
        </svg>
        <h2 className="text-base font-semibold text-accent">
          Info Box Kontainer Tersedia
        </h2>
      </div>
      
      <div className="grid gap-4 sm:grid-cols-2">
        {batches.map((batch) => (
          <BatchCard key={batch.id} batch={batch} now={now} />
        ))}
      </div>
    </div>
  )
}

function BatchCard({ batch, now }: { batch: { id: string; name: string; destinationCity: string; packageIds: string[]; expiryDate?: string }; now: Date }) {
  const { timeDisplay, isExpiringSoon } = formatTimeRemaining(batch.expiryDate, now)

  return (
    <div className="relative overflow-hidden rounded-xl bg-white p-4 shadow-[0px_0px_0.5px_0px_rgba(0,0,0,0.14),0px_1px_1px_0px_rgba(0,0,0,0.24)] transition-all duration-200 hover:shadow-[0px_2px_8px_rgba(0,0,0,0.12)]">
      {/* Green top accent */}
      <div className="absolute top-0 left-0 right-0 h-1 bg-primary" />
      
      <div className="absolute top-3 right-3">
        <span className="inline-flex items-center rounded-full bg-[#d4e9e2] px-2.5 py-1 text-xs font-semibold text-accent">
          {batch.packageIds.length} Paket
        </span>
      </div>
      
      <h3 className="font-semibold text-sm text-[rgba(0,0,0,0.87)] pr-20 truncate mt-2">
        {batch.name}
      </h3>
      
      <div className="mt-3 space-y-2">
        <div className="flex items-center text-xs text-muted-foreground">
          <svg className="w-3.5 h-3.5 mr-2 shrink-0 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
            <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z" />
          </svg>
          <span>Tujuan:</span>
          <span className="font-medium ml-1 text-[rgba(0,0,0,0.87)]">{batch.destinationCity}</span>
        </div>
        
        <div className="flex items-center text-xs text-muted-foreground">
          <svg className={`w-3.5 h-3.5 mr-2 shrink-0 ${isExpiringSoon ? 'text-destructive' : 'text-primary'}`} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Sisa waktu:</span>
          <span className={`font-medium ml-1 ${isExpiringSoon ? 'text-destructive' : 'text-[rgba(0,0,0,0.87)]'}`}>
            {timeDisplay}
          </span>
        </div>
      </div>
    </div>
  )
}

function formatTimeRemaining(expiryDate: string | undefined, now: Date): { timeDisplay: string; isExpiringSoon: boolean } {
  if (!expiryDate) return { timeDisplay: 'Menunggu kuota', isExpiringSoon: false }

  const expiry = new Date(expiryDate)
  const diff = expiry.getTime() - now.getTime()

  if (diff <= 0) return { timeDisplay: 'Waktu habis', isExpiringSoon: true }

  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((diff / (1000 * 60 * 60)) % 24)
  const mins = Math.floor((diff / 1000 / 60) % 60)

  if (days > 0) return { timeDisplay: `${days}h ${hours}j lagi`, isExpiringSoon: false }
  return { timeDisplay: `${hours}j ${mins}m lagi`, isExpiringSoon: hours < 12 }
}
