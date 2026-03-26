"use client";
import Link from "next/link";
import { useSettings } from "@/context/SettingsContext";

export default function Header() {
  const { settings } = useSettings();
  
  return (
    <header className="bg-paper/80 backdrop-blur-md sticky top-0 z-30 border-b border-gold/20">
      <nav className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
        <Link href="/" className="title-brush text-2xl font-bold text-ink">
          {settings.artistName}
        </Link>
        <ul className="hidden md:flex gap-10 text-sm font-semibold text-ink/80">
          <li><Link href="/" className="hover:text-gold transition">الرئيسية</Link></li>
          <li><Link href="/gallery" className="hover:text-gold transition">المعرض</Link></li>
          <li><Link href="/blog" className="hover:text-gold transition">المدونة</Link></li>
          <li><Link href="/about" className="hover:text-gold transition">من أنا</Link></li>
        </ul>
      </nav>
    </header>
  );
}
