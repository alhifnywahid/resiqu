import type { Metadata } from "next"
import { Inter } from "next/font/google"

import "./globals.css"

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
})

export const metadata: Metadata = {
  title: "Resiqu - Tracking Paket Transit",
  description:
    "Sistem tracking paket transit antar pulau. Lacak status paket Anda secara real-time.",
  keywords: ["tracking paket", "transit", "pengiriman", "resiqu"],
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="id" className={inter.variable}>
      <body>{children}</body>
    </html>
  )
}
