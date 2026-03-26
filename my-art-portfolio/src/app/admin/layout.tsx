"use client";
import AdminGuard from '@/components/AdminGuard';
import Link from 'next/link';
import { useAuth } from '@/context/AuthContext';
import { usePathname } from 'next/navigation';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { logout, user } = useAuth();
  const pathname = usePathname();
  
  // إذا كنا في صفحة تسجيل الدخول، لا نعرض القائمة الجانبية nor the guard
  if (pathname === '/admin/login') {
    return <>{children}</>;
  }

  return (
    <AdminGuard>
      <div className="min-h-screen bg-paper flex">
        
        {/* Sidebar */}
        <aside className="w-64 bg-ink text-white flex flex-col p-6 space-y-2 fixed h-full">
          <h2 className="text-2xl font-bold mb-8 text-gold">لوحة التحكم</h2>
          
          <Link href="/admin" className="block py-2 px-4 rounded hover:bg-white/10 transition">
            🏠 الرئيسية
          </Link>
          <Link href="/admin/paintings" className="block py-2 px-4 rounded hover:bg-white/10 transition">
            🖼️ اللوحات
          </Link>
          <Link href="/admin/blog" className="block py-2 px-4 rounded hover:bg-white/10 transition">
            📝 المدونة
          </Link>
          <Link href="/admin/settings" className="block py-2 px-4 rounded hover:bg-white/10 transition">
            ⚙️ الإعدادات
          </Link>
          
          <div className="mt-auto pt-6 border-t border-white/20">
            <p className="text-xs text-gray-400 mb-2 truncate">{user?.email}</p>
            <button onClick={logout} className="w-full text-right text-red-400 hover:text-red-300 text-sm">
              تسجيل الخروج
            </button>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 mr-64 p-8">
            {children}
        </main>
      </div>
    </AdminGuard>
  );
}
