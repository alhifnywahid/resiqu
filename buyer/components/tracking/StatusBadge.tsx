import { PackageStatus, PackageStatusLabel } from '@/types'
import { cn } from '@/lib/utils'

const statusConfig: Record<
  PackageStatus,
  { color: string; dot: string }
> = {
  diterima: {
    color: 'bg-blue-100 text-blue-700 border-blue-200',
    dot: 'bg-blue-500',
  },
  dalam_box: {
    color: 'bg-purple-100 text-purple-700 border-purple-200',
    dot: 'bg-purple-500',
  },
  dalam_perjalanan: {
    color: 'bg-indigo-100 text-indigo-700 border-indigo-200',
    dot: 'bg-indigo-500',
  },
  tiba_di_tujuan: {
    color: 'bg-teal-100 text-teal-700 border-teal-200',
    dot: 'bg-teal-500',
  },
  selesai: {
    color: 'bg-green-100 text-green-700 border-green-200',
    dot: 'bg-green-500',
  },
  kendala: {
    color: 'bg-red-100 text-red-700 border-red-200',
    dot: 'bg-red-500',
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
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full border font-medium',
        config.color,
        size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-3 py-1 text-sm'
      )}
    >
      <span className={cn('h-1.5 w-1.5 rounded-full', config.dot)} />
      {label}
    </span>
  )
}
