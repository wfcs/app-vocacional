import type { ButtonHTMLAttributes } from "react";

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "secondary" | "ghost";
};

const STYLES: Record<NonNullable<Props["variant"]>, string> = {
  primary:
    "bg-indigo-600 text-white hover:bg-indigo-700 disabled:bg-slate-300 disabled:cursor-not-allowed",
  secondary:
    "bg-white text-slate-900 border border-slate-300 hover:bg-slate-50 disabled:opacity-50",
  ghost: "text-slate-700 hover:bg-slate-100",
};

export default function Button({
  variant = "primary",
  className = "",
  ...rest
}: Props) {
  return (
    <button
      className={`inline-flex items-center justify-center px-4 py-2 rounded-md text-sm font-medium transition ${STYLES[variant]} ${className}`}
      {...rest}
    />
  );
}
