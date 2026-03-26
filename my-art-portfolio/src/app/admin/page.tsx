import Link from "next/link";

export default function AdminDashboard() {
  return (
    <div>
      <h1 className="text-3xl font-bold text-ink mb-8">مرحباً بك في لوحة التحكم</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        {/* بطاقة اللوحات */}
        <Link href="/admin/paintings" className="block bg-white p-8 rounded-lg shadow hover:shadow-lg transition group border-r-4 border-gold">
          <h2 className="text-xl font-bold text-ink group-hover:text-gold transition">إدارة اللوحات</h2>
          <p className="text-gray-500 mt-2 text-sm">إضافة، تعديل، وحذف اللوحات الفنية.</p>
        </Link>

        {/* بطاقة المدونة */}
        <Link href="/admin/blog" className="block bg-white p-8 rounded-lg shadow hover:shadow-lg transition group border-r-4 border-emerald">
          <h2 className="text-xl font-bold text-ink group-hover:text-emerald transition">إدارة المدونة</h2>
          <p className="text-gray-500 mt-2 text-sm">كتابة وتعديل المقالات الفنية.</p>
        </Link>

        {/* بطاقة الإعدادات */}
        <Link href="/admin/settings" className="block bg-white p-8 rounded-lg shadow hover:shadow-lg transition group border-r-4 border-sienna">
          <h2 className="text-xl font-bold text-ink group-hover:text-sienna transition">الإعدادات العامة</h2>
          <p className="text-gray-500 mt-2 text-sm">تعديل البيانات الشخصية ووسائل التواصل.</p>
        </Link>

      </div>
    </div>
  );
}
