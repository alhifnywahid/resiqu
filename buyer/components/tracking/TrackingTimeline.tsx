import { format } from 'date-fns'
import { id as idLocale } from 'date-fns/locale'

import type { StatusHistory } from '@/types'
import { PackageStatusLabel } from '@/types'

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
                className={`mt-1 h-3 w-3 shrink-0 rounded-full border-2 ${
                  isFirst
                    ? 'border-primary bg-primary'
                    : 'border-[#edebe9] bg-[#f9f9f9]'
                }`}
              />
              {!isLast && (
                <div className="my-1 w-0.5 flex-1 bg-[#edebe9]" />
              )}
            </div>

            {/* Content */}
            <div className={isLast ? 'pb-0' : 'pb-6'}>
              <p
                className={`text-sm font-semibold ${
                  isFirst ? 'text-accent' : 'text-muted-foreground'
                }`}
              >
                {PackageStatusLabel[item.status]}
              </p>
              {item.note && (
                <p className="mt-0.5 text-sm text-muted-foreground">
                  {item.note}
                </p>
              )}
              <p className="mt-1 text-xs text-[rgba(0,0,0,0.38)]">
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
