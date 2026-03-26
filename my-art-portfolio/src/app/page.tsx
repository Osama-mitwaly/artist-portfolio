"use client";
import Link from "next/link";
import { useSettings } from "@/context/SettingsContext";
import { usePaintings } from "@/hooks/usePaintings";
import PaintingCard from "@/components/PaintingCard";

export default function Home() {
  const { settings } = useSettings();
  const { paintings } = usePaintings();
  
  const featuredPaintings = paintings.filter(p => p.isFeatured).slice(0, 3);

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative h-[80vh] flex items-center justify-center text-center bg-gradient-to-b from-paper to-white overflow-hidden">
        <div className="absolute top-10 right-10 w-64 h-64 bg-gold/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-10 left-10 w-96 h-96 bg-sienna/10 rounded-full blur-3xl"></div>

        <div className="relative z-10 max-w-3xl mx-auto px-6 animate-fade-in">
          <h1 className="text-5xl md:text-7xl font-bold mb-6 text-ink">
            <span className="title-brush">{settings.artistName}</span>
          </h1>
          <p className="text-xl text-ink/70 mb-8 leading-relaxed">
            أرسم بالألوان الزيتية لأعبر عن صوت الروح. استكشف معرضي من اللوحات الفريدة التي تمزج بين الواقع والخيال.
          </p>
          <div className="flex justify-center gap-4">
            <Link href="/gallery" className="bg-ink text-white px-8 py-3 rounded font-bold hover:bg-gold transition duration-300 shadow-lg">
              زيارة المعرض
            </Link>
            <Link href="/about" className="border-2 border-ink text-ink px-8 py-3 rounded font-bold hover:bg-ink hover:text-white transition duration-300">
              قصتي
            </Link>
          </div>
        </div>
      </section>

      {/* Featured Section */}
      <section className="max-w-7xl mx-auto px-6 py-16">
        <h2 className="text-3xl font-bold text-center mb-12 text-ink title-brush">أعمال مميزة</h2>
        
        {featuredPaintings.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {featuredPaintings.map((painting) => (
              <PaintingCard key={painting.id} painting={painting} showStatus={false} />
            ))}
          </div>
        ) : (
          <div className="text-center text-gray-400 py-12 border-2 border-dashed border-gray-200 rounded-lg">
            <p>لم يتم تحديد لوحات مميزة بعد.</p>
            <p className="text-sm mt-2">اذهب للوحة التحكم واختر "عرض في الرئيسية".</p>
          </div>
        )}
        
      </section>
    </div>
  );
}
