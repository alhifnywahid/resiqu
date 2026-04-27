import type { Metadata } from "next"
import Link from "next/link"
import { notFound } from "next/navigation"
import { format } from "date-fns"
import { id as idLocale } from "date-fns/locale"

import { StatusBadge } from "@/components/tracking/StatusBadge"
import { TrackingForm } from "@/components/tracking/TrackingForm"
import { ShareButton } from "@/components/tracking/ShareButton"
import { TrackingTimeline } from "@/components/tracking/TrackingTimeline"
import { findPackageByCode } from "@/services/package-service"
import { Button } from "@/components/ui/button"

interface Props {
  params: Promise<{ code: string }>
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { code } = await params
  return {
    title: `Tracking ${decodeURIComponent(code)} - Resiqu`,
  }
}

export default async function TrackingPage({ params }: Props) {
  const { code } = await params
  const decodedCode = decodeURIComponent(code)

  const result = await findPackageByCode(decodedCode)

  if (!result) {
    return (
      <main className="flex min-h-svh flex-col items-center justify-center px-4 py-16 bg-slate-50 dark:bg-slate-950">
        <div className="w-full max-w-lg space-y-6 text-center">
          <span className="text-5xl">🔍</span>
          <div>
            <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Paket tidak ditemukan</h1>
            <p className="mt-2 text-slate-500 dark:text-slate-400">
              Nomor resi atau kode tracking{" "}
              <code className="rounded bg-slate-200 px-1 py-0.5 text-sm dark:bg-slate-800">
                {decodedCode}
              </code>{" "}
              tidak ditemukan dalam sistem.
            </p>
          </div>
          <Link href="/">
            <Button variant="outline" className="bg-white hover:bg-slate-100 dark:bg-slate-900 dark:hover:bg-slate-800">← Coba Kode Lain</Button>
          </Link>
        </div>
      </main>
    )
  }

  const { package: pkg, statusHistory } = result

  return (
    <main className="min-h-svh bg-slate-50 px-4 py-8 dark:bg-slate-950">
      <div className="mx-auto max-w-lg space-y-6">
        {/* Back + Search + Share */}
        <div className="flex items-center justify-between">
          <Link
            href="/"
            className="text-sm text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
          >
            ← Kembali
          </Link>
          <div className="flex items-center gap-2">
            <span className="text-sm font-semibold text-slate-900 dark:text-white">
              ResiQu
            </span>
            <ShareButton code={pkg.trackingCode} />
          </div>
        </div>

        {/* Status Card */}
        <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
          <div className="mb-4 flex items-start justify-between gap-3">
            <div>
              <p className="text-xs text-slate-500 dark:text-slate-400">Kode Tracking</p>
              <p className="font-mono text-sm font-semibold text-slate-900 dark:text-white">
                {pkg.trackingCode}
              </p>
            </div>
            <StatusBadge status={pkg.currentStatus} />
          </div>

          <div className="grid grid-cols-2 gap-3 border-t border-slate-100 pt-4 dark:border-slate-800">
            <div>
              <p className="text-xs text-slate-500 dark:text-slate-400">Penerima</p>
              <p className="text-sm font-medium text-slate-900 dark:text-white">{pkg.recipientName}</p>
            </div>
            <div>
              <p className="text-xs text-slate-500 dark:text-slate-400">Tujuan</p>
              <p className="text-sm font-medium text-slate-900 dark:text-white">{pkg.destinationCity}</p>
            </div>
            <div>
              <p className="text-xs text-slate-500 dark:text-slate-400">Resi Marketplace</p>
              <p className="font-mono text-sm text-slate-700 dark:text-slate-300">{pkg.marketplaceResi || '-'}</p>
            </div>
            <div>
              <p className="text-xs text-slate-500 dark:text-slate-400">Terakhir Diupdate</p>
              <p className="text-sm text-slate-700 dark:text-slate-300">
                {format(pkg.updatedAt, "dd MMM yyyy", { locale: idLocale })}
              </p>
            </div>
          </div>
        </div>

        {/* Timeline */}
        {statusHistory.length > 0 && (
          <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h2 className="mb-4 text-sm font-semibold text-slate-900 dark:text-white">Riwayat Status</h2>
            <TrackingTimeline history={statusHistory} />
          </div>
        )}

        {/* Search Again */}
        <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
          <p className="mb-3 text-sm font-medium text-slate-900 dark:text-white">Lacak paket lain</p>
          <TrackingForm />
        </div>
      </div>
    </main>
  )
}
