#!/bin/bash

echo "🔗 جاري تصحيح روابط التليجرام بناءً على الإعدادات..."

# ---------------------------------------------------------
# 1. تحديث CartContext (السلة) - المنطق الصحيح للرابط
# ---------------------------------------------------------
cat << 'EOF' > src/context/CartContext.tsx
"use client";
import React, { createContext, useContext, useState, ReactNode } from 'react';
import { useSettings } from './SettingsContext';

interface Painting {
  id: string;
  title: string;
  price: number;
  imageUrl: string;
}

interface CartContextType {
  cart: Painting[];
  addToCart: (painting: Painting) => void;
  removeFromCart: (id: string) => void;
  clearCart: () => void;
  totalItems: number;
  sendOrder: (platform: 'whatsapp' | 'telegram') => void;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export const CartProvider = ({ children }: { children: ReactNode }) => {
  const { settings } = useSettings();
  const [cart, setCart] = useState<Painting[]>([]);

  const addToCart = (painting: Painting) => {
    setCart((prev) => {
      if (prev.find((item) => item.id === painting.id)) return prev;
      return [...prev, painting];
    });
  };

  const removeFromCart = (id: string) => {
    setCart((prev) => prev.filter((item) => item.id !== id));
  };

  const clearCart = () => setCart([]);

  const sendOrder = (platform: 'whatsapp' | 'telegram') => {
    if (cart.length === 0) return;

    const itemsList = cart.map(p => `• ${p.title}`).join('\n');
    const message = `مرحباً، أنا مهتم باللوحات التالية:\n\n${itemsList}`;
    const encodedMessage = encodeURIComponent(message);

    let url = '';
    
    if (platform === 'whatsapp') {
        let waNum = settings.whatsapp.replace(/\s|-/g, '');
        if (waNum.startsWith("0")) waNum = "2" + waNum;
        url = `https://wa.me/${waNum}?text=${encodedMessage}`;
    } else {
        // منطق التليجرام المحدث
        const type = settings.telegramType;
        let val = settings.telegramValue;
        
        if (type === 'username') {
            // إزالة @ إذا وجدت
            val = val.replace('@', '');
            url = `https://t.me/${val}?text=${encodedMessage}`;
        } else {
            // رقم هاتف
            let phone = val.replace(/\D/g, ''); // إزالة أي شيء غير أرقام
            if (phone.startsWith("0")) phone = "2" + phone; // تحويل للصيغة الدولية
            url = `https://t.me/+${phone}`; // الرابط الرسمي للأرقام
        }
    }
    
    if(url) window.open(url, '_blank');
  };

  const totalItems = cart.length;

  return (
    <CartContext.Provider value={{ cart, addToCart, removeFromCart, clearCart, totalItems, sendOrder }}>
      {children}
    </CartContext.Provider>
  );
};

export const useCart = () => {
  const context = useContext(CartContext);
  if (!context) throw new Error('useCart must be used within CartProvider');
  return context;
};
EOF

# ---------------------------------------------------------
# 2. تحديث صفحة "من أنا" (About Page)
# ---------------------------------------------------------
cat << 'EOF' > src/app/about/page.tsx
"use client";
import { useSettings } from "@/context/SettingsContext";

export default function AboutPage() {
  const { settings } = useSettings();

  const getWALink = () => {
    let num = settings.whatsapp.replace(/\s|-/g, '');
    if (num.startsWith("0")) num = "2" + num;
    return `https://wa.me/${num}`;
  };

  const getTGLink = () => {
    const type = settings.telegramType;
    let val = settings.telegramValue;
    
    if (type === 'username') {
        val = val.replace('@', '');
        return `https://t.me/${val}`;
    } else {
        let phone = val.replace(/\D/g, '');
        if (phone.startsWith("0")) phone = "2" + phone;
        return `https://t.me/+${phone}`;
    }
  };
  
  return (
    <div className="max-w-4xl mx-auto px-4 py-12">
      <h1 className="text-3xl font-bold mb-8 text-center">من أنا</h1>
      
      <div className="bg-white rounded-lg shadow p-8 md:flex gap-8 items-center">
        <div className="w-48 h-48 bg-gray-200 rounded-full mx-auto mb-6 md:mb-0 flex items-center justify-center text-gray-400 flex-shrink-0 overflow-hidden border-4 border-gold">
          {settings.profileImage ? (
            <img src={settings.profileImage} alt="Profile" className="w-full h-full object-cover" />
          ) : (
            <span>صورتي</span>
          )}
        </div>
        <div className="flex-1 text-center md:text-right">
          <h2 className="text-2xl font-bold mb-4">{settings.artistName}</h2>
          <p className="text-gray-600 leading-relaxed whitespace-pre-line mb-6">
            {settings.bio || "لم يتم كتابة نبذة بعد."}
          </p>

          <div className="flex justify-center md:justify-start gap-4 border-t pt-4 mt-4">
            <a 
               href={getWALink()} 
               target="_blank"
               className="flex items-center gap-2 bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 transition"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
              واتساب
            </a>
            <a 
               href={getTGLink()} 
               target="_blank"
               className="flex items-center gap-2 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition"
            >
               <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 24 24" fill="currentColor"><path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z"/></svg>
              تيليجرام
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 3. تحديث الفوتر (Footer)
# ---------------------------------------------------------
cat << 'EOF' > src/components/Footer.tsx
"use client";
import { useSettings } from "@/context/SettingsContext";

export default function Footer() {
  const { settings } = useSettings();

  const getWALink = () => {
    let num = settings.whatsapp.replace(/\s|-/g, '');
    if (num.startsWith("0")) num = "2" + num;
    return `https://wa.me/${num}`;
  };

  const getTGLink = () => {
    const type = settings.telegramType;
    let val = settings.telegramValue;
    
    if (type === 'username') {
        val = val.replace('@', '');
        return `https://t.me/${val}`;
    } else {
        let phone = val.replace(/\D/g, '');
        if (phone.startsWith("0")) phone = "2" + phone;
        return `https://t.me/+${phone}`;
    }
  };

  return (
    <footer className="bg-ink text-paper mt-20">
      <div className="max-w-7xl mx-auto px-6 py-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8 border-b border-paper/20 pb-8">
          <div>
            <h3 className="text-2xl font-bold text-gold mb-4">{settings.artistName}</h3>
            <p className="text-paper/70 text-sm leading-relaxed">
              {settings.bio}
            </p>
          </div>

          <div>
             <h4 className="text-lg font-bold mb-4 text-paper">روابط مهمة</h4>
             <ul className="space-y-2 text-paper/70 text-sm">
               <li><a href="/gallery" className="hover:text-gold transition">استعرض المعرض</a></li>
               <li><a href="/about" className="hover:text-gold transition">عن الفنان</a></li>
               <li><a href="/blog" className="hover:text-gold transition">المدونة</a></li>
             </ul>
          </div>

          <div>
             <h4 className="text-lg font-bold mb-4 text-paper">تواصل معي</h4>
             <div className="flex gap-3">
               <a href={settings.facebook} target="_blank" className="bg-paper/10 p-2 rounded hover:bg-gold transition"><svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M18.77,7.46H14.5v-1.9c0-.9.6-1.1,1-1.1h3V.5h-4.33C10.24.5,9.5,3.44,9.5,5.32v2.15h-3v4h3v12h5v-12h3.85l.42-4Z"/></svg></a>
               <a href={settings.instagram} target="_blank" className="bg-paper/10 p-2 rounded hover:bg-gold transition"><svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12,2.16c3.2,0,3.58,0,4.85.07,3.25.15,4.77,1.69,4.92,4.92.06,1.27.07,1.65.07,4.85s0,3.58-.07,4.85c-.15,3.23-1.66,4.77-4.92,4.92-1.27.06-1.65.07-4.85.07s-3.58,0-4.85-.07c-3.26-.15-4.77-1.7-4.92-4.92-.06-1.27-.07-1.65-.07-4.85s0-3.58.07-4.85C2.38,3.92,3.9,2.38,7.15,2.23,8.42,2.18,8.8,2.16,12,2.16ZM12,0C8.74,0,8.33,0,7.05.07c-4.35.2-6.78,2.62-7,7C0,8.33,0,8.74,0,12s0,3.67.07,4.95c.2,4.36,2.62,6.78,7,7C8.33,24,8.74,24,12,24s3.67,0,4.95-.07c4.35-.2,6.78-2.62,7-7C24,15.67,24,15.26,24,12s0-3.67-.07-4.95c-.2-4.35-2.62-6.78-7-7C15.67,0,15.26,0,12,0Zm0,5.84A6.16,6.16,0,1,0,18.16,12,6.16,6.16,0,0,0,12,5.84ZM12,16a4,4,0,1,1,4-4A4,4,0,0,1,12,16ZM18.41,4.15a1.44,1.44,0,1,0,1.44,1.44A1.44,1.44,0,0,0,18.41,4.15Z"/></svg></a>
               <a href={getTGLink()} target="_blank" className="bg-paper/10 p-2 rounded hover:bg-gold transition"><svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z"/></svg></a>
               <a href={settings.tiktok} target="_blank" className="bg-paper/10 p-2 rounded hover:bg-gold transition"><svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M19.59,6.69a4.83,4.83,0,0,1-3.77-4.25V2h-3.45V13.4a2.89,2.89,0,0,1-5.2,1.74,2.89,2.89,0,0,1,2.31-4.64,2.93,2.93,0,0,1,.88.13V7.26a6.33,6.33,0,0,0-1-.08A6.34,6.34,0,0,0,6,13.4a6.34,6.34,0,0,0,6.34,6.34A6.34,6.34,0,0,0,18.68,13.4V7.84a7.87,7.87,0,0,0,4.32,1.3V5.7A4.57,4.57,0,0,1,19.59,6.69Z"/></svg></a>
               <a href={settings.twitter} target="_blank" className="bg-paper/10 p-2 rounded hover:bg-gold transition"><svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg></a>
             </div>
          </div>
        </div>
        
        <p className="text-center text-paper/50 text-xs">
          جميع الحقوق محفوظة © 2024 {settings.artistName}
        </p>
      </div>
    </footer>
  );
}
EOF

echo "✅ تم تحديث الأيقونات لتستخدم القيمة والنوع المحدد في الإعدادات بدقة."
echo "➡️ شغل السيرفر: npm run dev"
