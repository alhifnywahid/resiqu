import type { Metadata } from "next"

import { TrackingForm } from "@/components/tracking/TrackingForm"
import { OpenBatches } from "@/components/OpenBatches"

export const metadata: Metadata = {
  title: "Resiqu - Cek Status Paket Transit",
  description:
    "Lacak status paket Anda yang sedang dalam proses transit antar pulau dengan sistem tracking Resiqu.",
}



export default function HomePage() {
  return (
    <main className="flex min-h-svh flex-col bg-slate-50 dark:bg-slate-950">
      {/* Hero Section */}
      <section className="flex flex-1 flex-col items-center justify-center px-4 py-16">
        <div className="w-full max-w-xl space-y-10">
          {/* Branding */}
          <div className="space-y-4 text-center">
            <div className="inline-flex items-center justify-center gap-3">
              <span className="text-4xl">📦</span>
              <h1 className="text-4xl font-bold tracking-tight text-blue-600 dark:text-blue-500">
                ResiQu
              </h1>
            </div>
            <div>
              <p className="text-xl font-medium text-slate-800 dark:text-slate-200">
                Lacak Paket Anda
              </p>
              <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
                Masukkan nomor resi untuk melihat status pengiriman secara real-time
              </p>
            </div>
          </div>

          {/* Tracking Card */}
          <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <TrackingForm />
          </div>

          <OpenBatches />
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-200 py-6 text-center text-sm text-slate-500 dark:border-slate-800 dark:text-slate-400">
        © {new Date().getFullYear()} ResiQu · Layanan transit terpercaya
      </footer>
    </main>
  )
}
