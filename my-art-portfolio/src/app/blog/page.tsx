"use client";
import Link from "next/link";
import { usePosts } from "@/hooks/usePosts";

export default function BlogPage() {
  const { posts, loading } = usePosts();

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 text-center text-gray-400">
        جاري تحميل المقالات...
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-12">
      <h1 className="text-3xl font-bold mb-8 text-center">المدونة الفنية</h1>
      
      {posts.length === 0 ? (
        <div className="text-center py-20 text-gray-400 bg-white rounded-lg shadow">
          لا توجد مقالات منشورة حالياً.
        </div>
      ) : (
        <div className="space-y-8">
          {posts.map((post) => (
            <div key={post.id} className="bg-white rounded-lg shadow overflow-hidden md:flex hover:shadow-lg transition group">
              {/* صورة المقال */}
              <div className="md:w-1/3 h-56 md:h-auto relative bg-gray-100 overflow-hidden">
                {post.imageUrl ? (
                   <img src={post.imageUrl} alt={post.title} className="w-full h-full object-cover group-hover:scale-105 transition duration-300" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-300">لا توجد صورة</div>
                )}
              </div>
              
              {/* محتوى المقال */}
              <div className="p-6 md:w-2/3 flex flex-col justify-center">
                <h3 className="text-xl font-bold mb-2 text-ink group-hover:text-gold transition">{post.title}</h3>
                <p className="text-gray-500 text-xs mb-3">{new Date(post.date).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
                <p className="text-gray-600 line-clamp-3 mb-4">{post.content}</p>
                
                {/* زر اقرأ المزيد */}
                <Link href={`/blog/${post.id}`} className="text-gold font-bold hover:underline self-start flex items-center gap-1">
                  اقرأ المزيد
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
                  </svg>
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
