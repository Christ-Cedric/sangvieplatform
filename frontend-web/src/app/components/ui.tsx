import React from "react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const Button = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement> & {
    variant?: "primary" | "secondary" | "ghost" | "danger";
    size?: "sm" | "md" | "lg";
  }
>(({ className, variant = "primary", size = "md", ...props }, ref) => {
  const baseStyles =
    "inline-flex items-center justify-center font-semibold rounded-xl transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none active:scale-[0.97] select-none";
  const variants = {
    primary:
      "bg-[#CC0000] text-white hover:bg-[#B00000] focus-visible:ring-[#CC0000] shadow-[0_4px_14px_rgba(204,0,0,0.35)] hover:shadow-[0_6px_20px_rgba(204,0,0,0.45)] hover:-translate-y-0.5",
    secondary:
      "bg-white border border-[#E0E0E0] text-[#111111] hover:border-[#CC0000] hover:text-[#CC0000] hover:bg-[#FFF5F5] shadow-sm",
    ghost:
      "bg-transparent text-[#444444] hover:bg-[#F5F5F5] hover:text-[#111111]",
    danger:
      "bg-gradient-to-br from-[#FF0000] to-[#CC0000] text-white hover:from-[#E00000] hover:to-[#B00000] shadow-[0_4px_14px_rgba(255,0,0,0.3)]",
  };
  const sizes = {
    sm: "h-8 px-3 text-xs gap-1.5",
    md: "h-11 px-5 text-sm gap-2",
    lg: "h-14 px-8 text-base gap-2.5",
  };
  return (
    <button
      ref={ref}
      className={cn(baseStyles, variants[variant], sizes[size], className)}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
      {...props}
    />
  );
});
Button.displayName = "Button";

export const Input = React.forwardRef<
  HTMLInputElement,
  React.InputHTMLAttributes<HTMLInputElement> & { error?: string }
>(({ className, error, ...props }, ref) => {
  return (
    <div className="w-full">
      <input
        ref={ref}
        className={cn(
          "flex h-11 w-full rounded-xl border border-[#E0E0E0] bg-[#FAFAFA] px-4 py-2 text-sm text-[#111111]",
          "placeholder:text-[#BDBDBD] transition-all duration-200",
          "focus:outline-none focus:border-[#CC0000] focus:ring-4 focus:ring-[#CC0000]/10 focus:bg-white",
          "hover:border-[#BDBDBD]",
          "disabled:cursor-not-allowed disabled:opacity-50 disabled:bg-[#F5F5F5]",
          error && "border-[#FF0000] focus:border-[#FF0000] focus:ring-[#FF0000]/10",
          className
        )}
        style={{ fontFamily: "'DM Sans', sans-serif" }}
        {...props}
      />
      {error && (
        <span
          className="text-[#FF0000] text-xs mt-1.5 flex items-center gap-1"
          style={{ fontFamily: "'DM Sans', sans-serif" }}
        >
          <svg className="w-3 h-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
          </svg>
          {error}
        </span>
      )}
    </div>
  );
});
Input.displayName = "Input";

export const Badge = ({
  children,
  variant = "default",
  className,
}: {
  children: React.ReactNode;
  variant?:
    | "critical"
    | "moderate"
    | "low"
    | "active"
    | "inactive"
    | "pending"
    | "default"
    | "success"
    | "warning";
  className?: string;
}) => {
  const variants = {
    critical: "bg-[#CC0000] text-white shadow-sm",
    moderate: "bg-[#D4720B] text-white shadow-sm",
    low: "bg-[#1A7A3F] text-white shadow-sm",
    active: "bg-[#E8F5EE] text-[#1A7A3F] border border-[#1A7A3F]/20",
    inactive: "bg-[#F5F5F5] text-[#888888] border border-[#E0E0E0]",
    pending: "bg-[#FFF4E5] text-[#D4720B] border border-[#D4720B]/20",
    success: "bg-[#E8F5E9] text-[#1A7A3F] border border-[#1A7A3F]/20",
    warning: "bg-[#FFF4E5] text-[#D4720B] border border-[#D4720B]/20",
    default: "bg-[#F0F0F0] text-[#555555] border border-[#E0E0E0]",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold tracking-wide",
        variants[variant],
        className
      )}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      {children}
    </span>
  );
};

export const Card = ({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) => (
  <div
    className={cn(
      "bg-white rounded-2xl border border-[#EBEBEB] p-5 shadow-[0_1px_8px_rgba(0,0,0,0.05)] transition-shadow duration-200 hover:shadow-[0_4px_20px_rgba(0,0,0,0.09)]",
      className
    )}
  >
    {children}
  </div>
);

export const Typography = {
  H1: ({
    children,
    className,
  }: {
    children: React.ReactNode;
    className?: string;
  }) => (
    <h1
      className={cn(
        "text-[32px] md:text-[48px] text-[#0A0A0A] leading-[1.15] font-bold tracking-tight",
        className
      )}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      {children}
    </h1>
  ),
  H2: ({
    children,
    className,
  }: {
    children: React.ReactNode;
    className?: string;
  }) => (
    <h2
      className={cn(
        "text-[20px] md:text-[26px] text-[#111111] leading-snug font-semibold",
        className
      )}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      {children}
    </h2>
  ),
  H3: ({
    children,
    className,
  }: {
    children: React.ReactNode;
    className?: string;
  }) => (
    <h3
      className={cn(
        "text-[16px] md:text-[18px] text-[#111111] leading-snug font-semibold",
        className
      )}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      {children}
    </h3>
  ),
  Body: ({
    children,
    className,
  }: {
    children: React.ReactNode;
    className?: string;
  }) => (
    <p
      className={cn("text-[14px] md:text-[15px] text-[#555555] leading-relaxed", className)}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      {children}
    </p>
  ),
  Small: ({
    children,
    className,
  }: {
    children: React.ReactNode;
    className?: string;
  }) => (
    <span
      className={cn("text-[11px] md:text-[12px] text-[#888888] font-medium tracking-wide", className)}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      {children}
    </span>
  ),
};