import type { Timestamp } from 'firebase/firestore'

type FirestoreTimestamp = Timestamp | { toDate: () => Date }

/**
 * Safely converts Firestore Timestamp, Date, or string to a JS Date.
 * Returns current date as fallback for null/undefined values.
 */
export function toDate(ts: FirestoreTimestamp | Date | string | null | undefined): Date {
  if (!ts) return new Date()
  if (ts instanceof Date) return ts
  if (typeof ts === 'string') return new Date(ts)
  if ('toDate' in ts && typeof ts.toDate === 'function') return ts.toDate()
  return new Date()
}
