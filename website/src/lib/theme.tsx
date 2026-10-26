"use client";
import { createContext, useContext, useEffect, useState, ReactNode } from "react";
type Theme = "light" | "dark";
const Ctx = createContext<{ theme: Theme; toggle: () => void }>({ theme: "light", toggle: () => {} });
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<Theme>("light");
  useEffect(() => {
    const s = (localStorage.getItem("sm") as Theme) || "light";
    setTheme(s);
    document.documentElement.setAttribute("data-theme", s);
  }, []);
  const toggle = () => setTheme(p => {
    const n = p === "light" ? "dark" : "light";
    localStorage.setItem("sm", n);
    document.documentElement.setAttribute("data-theme", n);
    return n;
  });
  return <Ctx.Provider value={{ theme, toggle }}>{children}</Ctx.Provider>;
}
export const useTheme = () => useContext(Ctx);
