import { PackageStatus, PackageStatusLabel } from '@/types'

const statusConfig: Record<
  PackageStatus,
  { bg: string; text: string; dot: string }
> = {
  diterima: {
    bg: 'bg-[#d4e9e2]',
    text: 'text-[#006241]',
    dot: 'bg-[#00754A]',
  },
  dalam_box: {
    bg: 'bg-[#ede9fe]',
    text: 'text-[#5b21b6]',
    dot: 'bg-[#7c3aed]',
  },
  dalam_perjalanan: {
    bg: 'bg-[#dbeafe]',
    text: 'text-[#1e40af]',
    dot: 'bg-[#2563eb]',
  },
  tiba_di_tujuan: {
    bg: 'bg-[#d4e9e2]',
    text: 'text-[#1E3932]',
    dot: 'bg-[#2b5148]',
  },
  selesai: {
    bg: 'bg-[#d4e9e2]',
    text: 'text-[#006241]',
    dot: 'bg-[#00754A]',
  },
  kendala: {
    bg: 'bg-[#fee2e2]',
    text: 'text-[#991b1b]',
    dot: 'bg-[#c82014]',
  },
}

interface StatusBadgeProps {
  status: PackageStatus
  size?: 'sm' | 'md'
}

export function StatusBadge({ status, size = 'md' }: StatusBadgeProps) {
  const config = statusConfig[status]
  const label = PackageStatusLabel[status]

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full font-semibold ${config.bg} ${config.text} ${
        size === 'sm' ? 'px-2 py-0.5 text-[11px]' : 'px-3 py-1 text-[13px]'
      }`}
    >
      <span className={`h-1.5 w-1.5 rounded-full ${config.dot}`} />
      {label}
    </span>
  )
}
