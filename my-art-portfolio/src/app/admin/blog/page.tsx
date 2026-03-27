"use client";
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, getDocs, deleteDoc, doc, addDoc, updateDoc, query, orderBy } from 'firebase/firestore';
import Modal from '@/components/ui/Modal';
import ConfirmDialog from '@/components/ui/ConfirmDialog';
import toast from 'react-hot-toast';

interface Post {
  id: string;
  title: string;
  content: string;
  imageUrl: string;
  date: string;
}

export default function AdminBlog() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const emptyForm = { title: '', content: '', imageUrl: '' };
  const [form, setForm] = useState(emptyForm);
  const [editId, setEditId] = useState<string | null>(null);

  const fetchPosts = async () => {
    const q = query(collection(db, 'blog'), orderBy('date', 'desc'));
    const snap = await getDocs(q);
    const data = snap.docs.map(doc => ({ id: doc.id, ...doc.data() } as Post));
    setPosts(data);
    setLoading(false);
  };

  useEffect(() => { fetchPosts(); }, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await addDoc(collection(db, 'blog'), { ...form, date: new Date().toISOString() });
      toast.success('تم نشر المقال');
      setIsAddOpen(false);
      setForm(emptyForm);
      fetchPosts(); 
    } catch (err) { 
      console.error(err);
      toast.error('خطأ'); 
    }
  };

  const openEdit = (post: Post) => {
    setEditId(post.id);
    setForm({ title: post.title, content: post.content, imageUrl: post.imageUrl });
    setIsEditOpen(true);
  };

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if(!editId) return;
    try {
      await updateDoc(doc(db, 'blog', editId), form);
      toast.success('تم التعديل');
      setIsEditOpen(false);
      fetchPosts(); 
    } catch(err) { 
      console.error(err);
      toast.error('خطأ'); 
    }
  };

  const handleDelete = async () => {
    if(!deleteId) return;
    try {
      await deleteDoc(doc(db, 'blog', deleteId));
      toast.success('تم الحذف');
      setDeleteId(null);
      fetchPosts(); 
    } catch (err) {
      console.error(err);
      toast.error('خطأ');
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-ink">إدارة المدونة</h1>
        <button onClick={() => { setForm(emptyForm); setIsAddOpen(true); }} className="bg-emerald text-white px-6 py-2 rounded font-bold hover:opacity-90">
          + مقال جديد
        </button>
      </div>

      <div className="bg-white rounded shadow overflow-x-auto">
        <table className="min-w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">العنوان</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">التاريخ</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {loading ? (
              <tr><td colSpan={3} className="text-center p-4">جاري التحميل...</td></tr>
            ) : (
              posts.map((p) => (
                <tr key={p.id}>
                  <td className="px-6 py-4 font-medium">{p.title}</td>
                  <td className="px-6 py-4 text-gray-500">{new Date(p.date).toLocaleDateString('ar-EG')}</td>
                  <td className="px-6 py-4 space-x-2 space-x-reverse">
                    <button onClick={() => openEdit(p)} className="text-blue-600 hover:underline text-sm">تعديل</button>
                    <button onClick={() => setDeleteId(p.id)} className="text-red-600 hover:underline text-sm">حذف</button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <Modal isOpen={isAddOpen} onClose={() => setIsAddOpen(false)} title="مقال جديد">
        <form onSubmit={handleAdd} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">العنوان</label>
            <input value={form.title} onChange={(e) => setForm({...form, title: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">رابط الصورة</label>
            <input value={form.imageUrl} onChange={(e) => setForm({...form, imageUrl: e.target.value})} className="w-full p-2 border rounded" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">المحتوى</label>
            <textarea required value={form.content} onChange={(e) => setForm({...form, content: e.target.value})} className="w-full p-2 border rounded h-40" />
          </div>
          <button className="w-full bg-ink text-white py-2 rounded font-bold">نشر</button>
        </form>
      </Modal>

      <Modal isOpen={isEditOpen} onClose={() => setIsEditOpen(false)} title="تعديل المقال">
        <form onSubmit={handleUpdate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">العنوان</label>
            <input value={form.title} onChange={(e) => setForm({...form, title: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
           <div>
            <label className="block text-sm font-medium mb-1">رابط الصورة</label>
            <input value={form.imageUrl} onChange={(e) => setForm({...form, imageUrl: e.target.value})} className="w-full p-2 border rounded" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">المحتوى</label>
            <textarea required value={form.content} onChange={(e) => setForm({...form, content: e.target.value})} className="w-full p-2 border rounded h-40" />
          </div>
          <button className="w-full bg-ink text-white py-2 rounded font-bold">حفظ</button>
        </form>
      </Modal>

      <ConfirmDialog isOpen={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={handleDelete} message="هل تريد حذف هذا المقال؟" />
    </div>
  );
}
