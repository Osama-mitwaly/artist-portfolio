"use client";
import PaintingCard from "@/components/PaintingCard";
import { usePaintings } from "@/hooks/usePaintings";

export default function GalleryPage() {
  const { paintings, loading } = usePaintings();

  return (
    <div className="max-w-7xl mx-auto px-6 py-16">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4 text-ink">المعرض الفني</h1>
        <p className="text-gray-600 max-w-xl mx-auto">
          اختر اللوحات التي تلامس روحك، وأضفها للسلة لطلبها مباشرة عبر واتساب أو تيليجرام.
        </p>
      </div>
      
      {loading ? (
        <div className="text-center text-gray-400 py-20">جاري تحميل اللوحات...</div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
          {paintings.map((painting) => (
            <PaintingCard key={painting.id} painting={painting} />
          ))}
        </div>
      )}

      {!loading && paintings.length === 0 && (
        <div className="text-center py-20 text-gray-400">
          لا توجد لوحات حالياً، قم بإضافتها من لوحة التحكم.
        </div>
      )}
    </div>
  );
}
