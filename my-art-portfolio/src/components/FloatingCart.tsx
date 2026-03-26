"use client";
import { useCart } from '@/context/CartContext';
import { usePathname } from 'next/navigation'; // لمعرفة الصفحة الحالية
import { useState } from 'react';
import CartSidebar from './CartSidebar';

export default function FloatingCart() {
  const { totalItems } = useCart();
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();

  // إخفاء السلة إذا كان المسار يبدأ بـ /admin
  if (pathname.startsWith('/admin')) {
    return null;
  }

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-8 left-8 bg-gold text-white p-4 rounded-full shadow-2xl hover:bg-sienna transition duration-300 z-40 group"
      >
        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
        {totalItems > 0 && (
          <span className="absolute -top-2 -right-2 bg-ink text-white text-xs w-6 h-6 rounded-full flex items-center justify-center font-bold animate-bounce">
            {totalItems}
          </span>
        )}
      </button>

      {isOpen && <CartSidebar onClose={() => setIsOpen(false)} />}
    </>
  );
}
