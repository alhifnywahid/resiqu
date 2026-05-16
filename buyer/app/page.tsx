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
    <main className="flex min-h-svh flex-col bg-background">
      {/* Hero Section */}
      <section className="flex flex-1 flex-col items-center justify-center px-4 py-16">
        <div className="w-full max-w-xl space-y-10">
          {/* Branding */}
          <div className="space-y-3 text-center">
            <h1 className="text-4xl font-semibold tracking-tight text-accent">
              ResiQu
            </h1>
            <p className="text-lg font-medium text-[rgba(0,0,0,0.87)]">
              Lacak Paket Anda
            </p>
            <p className="text-sm text-muted-foreground">
              Masukkan nomor resi untuk melihat status pengiriman secara real-time
            </p>
          </div>

          {/* Tracking Card */}
          <div className="rounded-xl bg-white p-6 shadow-[0px_0px_0.5px_0px_rgba(0,0,0,0.14),0px_1px_1px_0px_rgba(0,0,0,0.24)]">
            <TrackingForm />
          </div>

          <OpenBatches />
        </div>
      </section>

      {/* Feature Band */}
      <section className="bg-[#1E3932] px-4 py-12 text-center">
        <div className="mx-auto max-w-xl space-y-3">
          <h2 className="text-lg font-semibold text-white">Layanan Transit Terpercaya</h2>
          <p className="text-sm text-[rgba(255,255,255,0.70)]">
            Pantau perjalanan paket Anda dari transit hingga tiba di tujuan dengan sistem tracking real-time.
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-[#1E3932] border-t border-[rgba(255,255,255,0.1)] py-6 text-center">
        <p className="text-sm text-[rgba(255,255,255,0.70)]">
          © {new Date().getFullYear()} ResiQu · Layanan transit terpercaya
        </p>
      </footer>
    </main>
  )
}
