"use client";
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';

export default function BlogPostPage() {
  const { id } = useParams();
  const router = useRouter();
  const [post, setPost] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPost = async () => {
      if (!id) return;
      const docRef = doc(db, 'blog', id as string);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setPost({ id: docSnap.id, ...docSnap.data() });
      } else {
        router.push('/blog'); // الرجوع للمدونة إذا لم يوجد المقال
      }
      setLoading(false);
    };
    fetchPost();
  }, [id, router]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-paper">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-gold"></div>
      </div>
    );
  }

  if (!post) return null;

  return (
    <div className="bg-paper min-h-screen py-12">
      <article className="max-w-3xl mx-auto px-4">
        {/* زر العودة */}
        <Link href="/blog" className="text-gold hover:underline mb-6 inline-block flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          العودة للمدونة
        </Link>

        {/* صورة المقال */}
        {post.imageUrl && (
          <div className="relative w-full h-64 md:h-96 rounded-lg overflow-hidden shadow-lg mb-8">
            <img src={post.imageUrl} alt={post.title} className="w-full h-full object-cover" />
          </div>
        )}

        {/* العنوان والتاريخ */}
        <h1 className="text-4xl font-bold text-ink mb-4 leading-tight">{post.title}</h1>
        <p className="text-gray-500 text-sm mb-8 border-b pb-4">
          {new Date(post.date).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}
        </p>

        {/* المحتوى */}
        <div className="prose prose-lg max-w-none text-ink/80 whitespace-pre-line">
          {post.content}
        </div>
      </article>
    </div>
  );
}
