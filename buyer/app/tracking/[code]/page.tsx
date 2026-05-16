import type { Metadata } from "next"
import Link from "next/link"
import { format } from "date-fns"
import { id as idLocale } from "date-fns/locale"

import { StatusBadge } from "@/components/tracking/StatusBadge"
import { TrackingForm } from "@/components/tracking/TrackingForm"
import { ShareButton } from "@/components/tracking/ShareButton"
import { TrackingTimeline } from "@/components/tracking/TrackingTimeline"
import { findPackageByCode } from "@/services/package-service"

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
      <main className="flex min-h-svh flex-col items-center justify-center bg-background px-4 py-16">
        <div className="w-full max-w-lg space-y-6 text-center">
          <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-[#d4e9e2]">
            <svg className="w-8 h-8 text-accent" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
            </svg>
          </div>
          <div>
            <h1 className="text-2xl font-semibold text-accent">
              Paket tidak ditemukan
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Nomor resi atau kode tracking{" "}
              <code className="rounded-full bg-secondary px-2 py-0.5 text-xs font-semibold text-[rgba(0,0,0,0.87)]">
                {decodedCode}
              </code>{" "}
              tidak ditemukan dalam sistem.
            </p>
          </div>
          <Link href="/">
            <button className="mt-4 rounded-4xl border border-primary bg-transparent px-5 py-2 text-sm font-semibold text-primary transition-all duration-200 hover:bg-[#d4e9e2] active:scale-95">
              ← Coba Kode Lain
            </button>
          </Link>
        </div>
      </main>
    )
  }

  const { package: pkg, statusHistory } = result

  return (
    <main className="min-h-svh bg-background px-4 py-8">
      <div className="mx-auto max-w-lg space-y-6">
        {/* Back + Brand + Share */}
        <div className="flex items-center justify-between">
          <Link
            href="/"
            className="text-sm font-semibold text-primary transition-colors hover:text-accent"
          >
            ← Kembali
          </Link>
          <div className="flex items-center gap-3">
            <span className="text-sm font-semibold text-accent">
              ResiQu
            </span>
            <ShareButton code={pkg.trackingCode} />
          </div>
        </div>

        {/* Status Card */}
        <div className="rounded-xl bg-white p-5 shadow-[0px_0px_0.5px_0px_rgba(0,0,0,0.14),0px_1px_1px_0px_rgba(0,0,0,0.24)]">
          <div className="mb-4 flex items-start justify-between gap-3">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Kode Tracking</p>
              <p className="font-mono text-sm font-semibold text-[rgba(0,0,0,0.87)]">
                {pkg.trackingCode}
              </p>
            </div>
            <StatusBadge status={pkg.currentStatus} />
          </div>

          <div className="grid grid-cols-2 gap-3 border-t border-secondary pt-4">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Penerima</p>
              <p className="text-sm font-semibold text-[rgba(0,0,0,0.87)]">{pkg.recipientName}</p>
            </div>
            <div>
              <p className="text-xs font-medium text-muted-foreground">Tujuan</p>
              <p className="text-sm font-semibold text-[rgba(0,0,0,0.87)]">{pkg.destinationCity}</p>
            </div>
            <div>
              <p className="text-xs font-medium text-muted-foreground">Resi Marketplace</p>
              <p className="font-mono text-sm text-[rgba(0,0,0,0.87)]">{pkg.marketplaceResi || '-'}</p>
            </div>
            <div>
              <p className="text-xs font-medium text-muted-foreground">Terakhir Diupdate</p>
              <p className="text-sm text-[rgba(0,0,0,0.87)]">
                {format(pkg.updatedAt, "dd MMM yyyy", { locale: idLocale })}
              </p>
            </div>
          </div>
        </div>

        {/* Timeline */}
        {statusHistory.length > 0 && (
          <div className="rounded-xl bg-white p-5 shadow-[0px_0px_0.5px_0px_rgba(0,0,0,0.14),0px_1px_1px_0px_rgba(0,0,0,0.24)]">
            <h2 className="mb-4 text-sm font-semibold text-accent">
              Riwayat Status
            </h2>
            <TrackingTimeline history={statusHistory} />
          </div>
        )}

        {/* Search Again */}
        <div className="rounded-xl bg-white p-5 shadow-[0px_0px_0.5px_0px_rgba(0,0,0,0.14),0px_1px_1px_0px_rgba(0,0,0,0.24)]">
          <p className="mb-3 text-sm font-semibold text-[rgba(0,0,0,0.87)]">Lacak paket lain</p>
          <TrackingForm />
        </div>
      </div>
    </main>
  )
}
