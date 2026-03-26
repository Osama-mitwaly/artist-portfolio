import type { Metadata } from "next";
import { Cairo } from "next/font/google";
import "./globals.css";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import FloatingCart from "@/components/FloatingCart";
import { CartProvider } from "@/context/CartContext";
import { AuthProvider } from "@/context/AuthContext";
import { SettingsProvider } from "@/context/SettingsContext"; // الجديد
import { Toaster } from "react-hot-toast";

const cairo = Cairo({ subsets: ["arabic", "latin"] });

export const metadata: Metadata = {
  title: "عبد الرحمن ناقشني - معرض فني",
  description: "معرض أعمال الفنان التشكيلي عبد الرحمن ناقشني، لوحات زيتية فنية للبيع.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className={`${cairo.className} bg-paper text-ink flex flex-col min-h-screen`}>
        <AuthProvider>
          <SettingsProvider> {/* الجديد */}
            <CartProvider>
              <Header />
              <main className="flex-grow">
                {children}
              </main>
              <FloatingCart />
              <Footer />
              <Toaster 
                position="top-center"
                toastOptions={{
                  duration: 3000,
                  style: {
                    background: '#2C1810',
                    color: '#FDFCF8',
                  },
                }}
              />
            </CartProvider>
          </SettingsProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
