export default function ProgressBar({ current, total }: { current: number; total: number }) {
  const pct = Math.min(100, Math.max(0, (current / total) * 100));
  return (
    <div className="space-y-1">
      <div className="flex justify-between text-xs text-slate-500">
        <span>Pergunta {Math.min(current, total)} de {total}</span>
        <span>{pct.toFixed(0)}%</span>
      </div>
      <div className="h-2 bg-slate-200 rounded">
        <div
          className="h-2 bg-indigo-600 rounded transition-all"
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}
