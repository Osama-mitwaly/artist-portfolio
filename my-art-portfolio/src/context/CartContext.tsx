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
