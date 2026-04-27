import { collection, query, where, getDocs } from 'firebase/firestore'

import { db } from '@/lib/firebase'
import { toDate } from '@/lib/date'
import type { Batch } from '@/types'

export async function getOpenBatches(): Promise<Batch[]> {
  try {
    const q = query(
      collection(db, 'batches'),
      where('status', '==', 'collecting'),
    )
    
    const snapshot = await getDocs(q)
    const batches: Batch[] = snapshot.docs.map((doc) => {
      const data = doc.data()
      return {
        id: doc.id,
        name: data.name,
        destinationCity: data.destinationCity,
        status: data.status,
        packageIds: data.packageIds || [],
        createdAt: toDate(data.createdAt).toISOString(),
        startDate: data.startDate ? toDate(data.startDate).toISOString() : undefined,
        expiryDate: data.expiryDate ? toDate(data.expiryDate).toISOString() : undefined,
      }
    })
    
    return batches.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
  } catch (error) {
    console.error('[batch-service] Failed to fetch open batches:', error)
    return []
  }
}
