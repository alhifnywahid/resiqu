import { format } from 'date-fns'
import { id as idLocale } from 'date-fns/locale'

import type { StatusHistory } from '@/types'
import { PackageStatusLabel } from '@/types'
import { cn } from '@/lib/utils'

interface TrackingTimelineProps {
  history: StatusHistory[]
}

export function TrackingTimeline({ history }: TrackingTimelineProps) {
  if (history.length === 0) return null

  return (
    <div className="space-y-0">
      {history.map((item, index) => {
        const isFirst = index === 0
        const isLast = index === history.length - 1
        return (
          <div key={item.id} className="flex gap-4">
            {/* Timeline connector */}
            <div className="flex flex-col items-center">
              <div
                className={cn(
                  'mt-1 h-3 w-3 shrink-0 rounded-full border-2',
                  isFirst
                    ? 'border-blue-600 bg-blue-600 dark:border-blue-500 dark:bg-blue-500'
                    : 'border-slate-300 bg-slate-50 dark:border-slate-600 dark:bg-slate-800'
                )}
              />
              {!isLast && (
                <div className="my-1 w-0.5 flex-1 bg-slate-200 dark:bg-slate-800" />
              )}
            </div>

            {/* Content */}
            <div className={cn('pb-6', isLast && 'pb-0')}>
              <p
                className={cn(
                  'text-sm font-semibold',
                  isFirst ? 'text-slate-900 dark:text-white' : 'text-slate-500 dark:text-slate-400'
                )}
              >
                {PackageStatusLabel[item.status]}
              </p>
              {item.note && (
                <p className="mt-0.5 text-sm text-slate-500 dark:text-slate-400">
                  {item.note}
                </p>
              )}
              <p className="mt-1 text-xs text-slate-400 dark:text-slate-500">
                {format(item.timestamp, 'dd MMM yyyy, HH:mm', {
                  locale: idLocale,
                })}
              </p>
            </div>
          </div>
        )
      })}
    </div>
  )
}
