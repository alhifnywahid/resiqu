import {
  collection,
  getDocs,
  orderBy,
  query,
  where,
} from 'firebase/firestore'

import { db } from '@/lib/firebase'
import { toDate } from '@/lib/date'
import type { Package, StatusHistory, TrackingResult } from '@/types'

export async function findPackageByCode(
  code: string
): Promise<TrackingResult | null> {
  const upperCode = code.trim().toUpperCase()

  // Try by trackingCode first
  let snapshot = await getDocs(
    query(
      collection(db, 'packages'),
      where('trackingCode', '==', upperCode)
    )
  )

  // Fallback: search by marketplaceResi
  if (snapshot.empty) {
    snapshot = await getDocs(
      query(
        collection(db, 'packages'),
        where('marketplaceResi', '==', code.trim())
      )
    )
  }

  if (snapshot.empty) return null

  const docSnap = snapshot.docs[0]
  const data = docSnap.data()

  const dims = data.dimensions
    ? { p: data.dimensions.p ?? 0, l: data.dimensions.l ?? 0, t: data.dimensions.t ?? 0 }
    : null

  const pkg: Package = {
    id: docSnap.id,
    trackingCode: data.trackingCode,
    marketplaceResi: data.marketplaceResi,
    recipientName: data.recipientName,
    recipientPhone: data.recipientPhone,
    destinationCity: data.destinationCity,
    currentStatus: data.currentStatus,
    batchId: data.batchId ?? null,
    dimensions: dims,
    createdBy: data.createdBy,
    updatedBy: data.updatedBy,
    createdAt: toDate(data.createdAt),
    updatedAt: toDate(data.updatedAt),
  }

  // Fetch status history sub-collection
  const historySnap = await getDocs(
    query(
      collection(db, `packages/${docSnap.id}/statusHistory`),
      orderBy('timestamp', 'desc')
    )
  )

  const statusHistory: StatusHistory[] = historySnap.docs.map((h) => {
    const hd = h.data()
    return {
      id: h.id,
      status: hd.status,
      note: hd.note ?? '',
      updatedBy: hd.updatedBy ?? '',
      timestamp: toDate(hd.timestamp),
    }
  })

  return { package: pkg, statusHistory }
}
