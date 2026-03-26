"use client";
import Image from "next/image";
import { useCart } from '@/context/CartContext';
import { siteConfig } from '@/config/siteConfig';

interface Props {
  painting: {
    id: string;
    title: string;
    description: string;
    price: number;
    imageUrl: string;
    isAvailable: boolean;
    isFeatured?: boolean;
  };
  showStatus?: boolean; // للتحكم في إظهار حالة "مباع"
}

export default function PaintingCard({ painting, showStatus = true }: Props) {
  const { addToCart } = useCart();

  const handleWhatsAppSingle = () => {
    const msg = `${siteConfig.messages.singleItemInquiry} "${painting.title}"`;
    const url = `https://wa.me/${siteConfig.whatsappNumber}?text=${encodeURIComponent(msg)}`;
    window.open(url, '_blank');
  };

  return (
    <div className="bg-white rounded-sm shadow-lg overflow-hidden group transition duration-500 hover:shadow-2xl border border-paper">
      <div className="relative h-72 bg-gray-100 overflow-hidden">
        {painting.imageUrl ? (
          <Image 
            src={painting.imageUrl} 
            alt={painting.title} 
            fill 
            className="object-cover group-hover:scale-105 transition duration-500"
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-300">لا توجد صورة</div>
        )}
        
        {showStatus && (
          <div className={`absolute top-4 right-4 px-3 py-1 rounded-full text-xs font-bold ${painting.isAvailable ? 'bg-emerald text-white' : 'bg-ink/70 text-white'}`}>
            {painting.isAvailable ? 'متاح للطلب' : 'مباع'}
          </div>
        )}
      </div>

      <div className="p-5 bg-paper">
        <h3 className="text-xl font-bold text-ink mb-2">{painting.title}</h3>
        <p className="text-gray-600 text-sm mb-4 line-clamp-2">{painting.description}</p>
        
        <div className="flex items-center justify-between">
          <span className="text-2xl font-bold text-gold">${painting.price}</span>
          
          {painting.isAvailable && (
            <button 
              onClick={() => addToCart(painting)}
              className="bg-ink text-white px-4 py-2 rounded text-sm font-bold hover:bg-gold transition"
            >
              أضف للسلة
            </button>
          )}
        </div>
        
        {!painting.isAvailable && (
           <button 
             onClick={handleWhatsAppSingle}
             className="mt-4 w-full text-center text-sm text-gray-500 hover:text-gold underline"
           >
             الاستفسار عن اللوحة
           </button>
        )}
      </div>
    </div>
  );
}
