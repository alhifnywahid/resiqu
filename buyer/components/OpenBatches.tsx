'use client'

import { PackageOpen, Clock, MapPin } from 'lucide-react'

import { useOpenBatches } from '@/hooks/use-open-batches'

export function OpenBatches() {
  const { batches, loading, now } = useOpenBatches()

  if (loading) {
    return (
      <div className="flex justify-center p-8">
        <div className="h-6 w-6 animate-spin rounded-full border-2 border-blue-500 border-t-transparent" />
      </div>
    )
  }

  if (batches.length === 0) {
    return (
      <div className="mt-8 text-center rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <PackageOpen className="w-8 h-8 text-slate-400 mx-auto mb-2" />
        <h3 className="text-sm font-medium text-slate-900 dark:text-white">Belum Ada Kontainer</h3>
        <p className="text-xs text-slate-500 mt-1">Saat ini belum ada jadwal transit kontainer yang tersedia.</p>
      </div>
    )
  }

  return (
    <div className="mt-8 space-y-4">
      <div className="flex items-center gap-2 mb-4">
        <PackageOpen className="w-5 h-5 text-blue-600 dark:text-blue-500" />
        <h2 className="text-base font-semibold text-slate-900 dark:text-white">
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
    <div className="relative overflow-hidden rounded-xl border border-slate-200 bg-white p-4 shadow-sm hover:shadow-md transition-shadow dark:border-slate-800 dark:bg-slate-900">
      <div className="absolute top-0 right-0 p-3">
        <span className="inline-flex items-center rounded bg-slate-100 px-2 py-1 text-xs font-medium text-slate-600 dark:bg-slate-800 dark:text-slate-300">
          {batch.packageIds.length} Paket
        </span>
      </div>
      
      <h3 className="font-semibold text-sm text-slate-900 dark:text-white pr-16 truncate">
        {batch.name}
      </h3>
      
      <div className="mt-3 space-y-1.5">
        <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
          <MapPin className="w-3.5 h-3.5 mr-2" />
          <span>Tujuan:</span>
          <span className="font-medium text-slate-900 dark:text-white ml-1">{batch.destinationCity}</span>
        </div>
        
        <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
          <Clock className={`w-3.5 h-3.5 mr-2 ${isExpiringSoon ? 'text-red-500' : ''}`} />
          <span>Sisa waktu:</span>
          <span className={`font-medium ml-1 ${isExpiringSoon ? 'text-red-500' : 'text-slate-900 dark:text-white'}`}>
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
