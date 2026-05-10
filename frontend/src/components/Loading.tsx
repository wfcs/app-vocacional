export default function Loading({ label = "Carregando..." }: { label?: string }) {
  return (
    <div className="flex items-center gap-3 text-slate-500 py-12 justify-center">
      <span className="inline-block h-4 w-4 rounded-full border-2 border-slate-300 border-t-indigo-600 animate-spin" />
      <span className="text-sm">{label}</span>
    </div>
  );
}
