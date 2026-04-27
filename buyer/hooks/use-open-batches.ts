'use client'

import { useEffect, useState } from 'react'

import { getOpenBatches } from '@/services/batch-service'
import type { Batch } from '@/types'

interface UseOpenBatchesReturn {
  batches: Batch[]
  loading: boolean
  now: Date
}

export function useOpenBatches(): UseOpenBatchesReturn {
  const [batches, setBatches] = useState<Batch[]>([])
  const [loading, setLoading] = useState(true)
  const [now, setNow] = useState(new Date())

  useEffect(() => {
    getOpenBatches()
      .then(setBatches)
      .finally(() => setLoading(false))

    const interval = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(interval)
  }, [])

  return { batches, loading, now }
}
