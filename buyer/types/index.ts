export type PackageStatus =
  | 'diterima'
  | 'dalam_box'
  | 'dalam_perjalanan'
  | 'tiba_di_tujuan'
  | 'selesai'
  | 'kendala'

export const PackageStatusLabel: Record<PackageStatus, string> = {
  diterima: 'Diterima',
  dalam_box: 'Dalam Box',
  dalam_perjalanan: 'Dalam Perjalanan',
  tiba_di_tujuan: 'Tiba di Tujuan',
  selesai: 'Selesai',
  kendala: 'Kendala',
}

export interface StatusHistory {
  id: string
  status: PackageStatus
  note: string
  updatedBy: string
  timestamp: Date
}

export interface PackageDimensions {
  p: number
  l: number
  t: number
}

export interface Package {
  id: string
  trackingCode: string
  marketplaceResi: string
  recipientName: string
  recipientPhone: string
  destinationCity: string
  currentStatus: PackageStatus
  batchId: string | null
  dimensions: PackageDimensions | null
  createdBy: string
  updatedBy: string
  createdAt: Date
  updatedAt: Date
  statusHistory?: StatusHistory[]
}

export interface TrackingResult {
  package: Package
  statusHistory: StatusHistory[]
}

export interface Batch {
  id: string
  name: string
  destinationCity: string
  status: string
  packageIds: string[]
  createdAt: string
  startDate?: string
  expiryDate?: string
}
