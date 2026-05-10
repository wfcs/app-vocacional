import { useEffect, useMemo, useState } from "react";
import { Cities } from "../api/endpoints";
import type { City } from "../types/api";

type Props = {
  value: City | null;
  onChange: (city: City | null) => void;
};

// Debounce simples sem dep externa
function useDebouncedValue<T>(value: T, ms: number) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), ms);
    return () => clearTimeout(t);
  }, [value, ms]);
  return debounced;
}

export default function CityCombobox({ value, onChange }: Props) {
  const [query, setQuery] = useState(value ? `${value.name} - ${value.state_code}` : "");
  const [open, setOpen] = useState(false);
  const [results, setResults] = useState<City[]>([]);
  const [loading, setLoading] = useState(false);
  const debounced = useDebouncedValue(query, 250);

  const showResults = useMemo(() => open && results.length > 0, [open, results.length]);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      if (debounced.trim().length < 2) {
        setResults([]);
        return;
      }
      setLoading(true);
      try {
        const cities = await Cities.list(debounced.trim(), 8);
        if (!cancelled) setResults(cities);
      } catch {
        if (!cancelled) setResults([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [debounced]);

  return (
    <div className="relative">
      <input
        type="text"
        value={query}
        onChange={(e) => {
          setQuery(e.target.value);
          if (value) onChange(null); // limpa seleção ao reeditar
          setOpen(true);
        }}
        onFocus={() => setOpen(true)}
        onBlur={() => setTimeout(() => setOpen(false), 150)}
        placeholder="Comece a digitar (ex.: São Paulo)"
        className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
        autoComplete="off"
      />
      {loading && (
        <div className="absolute right-3 top-2.5 text-xs text-slate-400">buscando…</div>
      )}
      {showResults && (
        <ul className="absolute z-10 mt-1 w-full max-h-56 overflow-auto rounded-md border border-slate-200 bg-white shadow-lg">
          {results.map((c) => (
            <li
              key={c.id}
              role="option"
              tabIndex={-1}
              className="px-3 py-2 text-sm cursor-pointer hover:bg-indigo-50"
              onMouseDown={(e) => {
                e.preventDefault();
                onChange(c);
                setQuery(`${c.name} - ${c.state_code}`);
                setOpen(false);
              }}
            >
              {c.name} <span className="text-slate-400">- {c.state_code}</span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
