#!/bin/bash

echo "🛠️ جاري إصلاح أخطاء الـ Build للنشر..."

# ---------------------------------------------------------
# 1. إصلاح صفحة المدونة (Admin Blog)
# ---------------------------------------------------------
cat << 'EOF' > src/app/admin/blog/page.tsx
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
EOF

# ---------------------------------------------------------
# 2. إصلاح صفحة اللوحات (Admin Paintings)
# ---------------------------------------------------------
cat << 'EOF' > src/app/admin/paintings/page.tsx
"use client";
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, getDocs, deleteDoc, doc, updateDoc, addDoc, Timestamp } from 'firebase/firestore';
import Modal from '@/components/ui/Modal';
import ConfirmDialog from '@/components/ui/ConfirmDialog';
import toast from 'react-hot-toast';

interface Painting {
  id: string;
  title: string;
  description: string;
  price: number;
  imageUrl: string;
  isAvailable: boolean;
  isFeatured: boolean;
}

export default function AdminPaintings() {
  const [paintings, setPaintings] = useState<Painting[]>([]);
  const [loading, setLoading] = useState(true);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  
  const emptyForm = { title: '', description: '', price: '', imageUrl: '', status: 'available', isFeatured: false };
  const [form, setForm] = useState(emptyForm);
  const [editId, setEditId] = useState<string | null>(null);

  const fetchPaintings = async () => {
    const querySnapshot = await getDocs(collection(db, 'paintings'));
    const data = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Painting));
    setPaintings(data);
    setLoading(false);
  };

  useEffect(() => { fetchPaintings(); }, []);

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await deleteDoc(doc(db, 'paintings', deleteId));
      toast.success('تم حذف اللوحة');
      setDeleteId(null);
      fetchPaintings();
    } catch (err) { 
      console.error(err);
      toast.error('حدث خطأ'); 
    }
  };

  const openEditModal = (painting: Painting) => {
    setEditId(painting.id);
    setForm({
      title: painting.title || '',
      description: painting.description || '',
      price: String(painting.price || 0),
      imageUrl: painting.imageUrl || '',
      status: painting.isAvailable ? 'available' : 'sold',
      isFeatured: painting.isFeatured || false,
    });
    setIsEditOpen(true);
  };

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editId) return;
    try {
      await updateDoc(doc(db, 'paintings', editId), {
        title: form.title,
        description: form.description,
        price: Number(form.price),
        imageUrl: form.imageUrl,
        isAvailable: form.status === 'available',
        isFeatured: form.isFeatured
      });
      toast.success('تم تحديث اللوحة');
      setIsEditOpen(false);
      fetchPaintings();
    } catch (err) { 
      console.error(err);
      toast.error('خطأ في التحديث'); 
    }
  };

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await addDoc(collection(db, 'paintings'), {
        title: form.title,
        description: form.description,
        price: Number(form.price),
        imageUrl: form.imageUrl,
        isAvailable: form.status === 'available',
        isFeatured: form.isFeatured,
        createdAt: Timestamp.now()
      });
      toast.success('تمت الإضافة بنجاح');
      setIsAddOpen(false);
      setForm(emptyForm);
      fetchPaintings();
    } catch (err) { 
      console.error(err);
      toast.error('خطأ في الإضافة'); 
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-ink">إدارة اللوحات</h1>
        <button onClick={() => { setForm(emptyForm); setIsAddOpen(true); }} className="bg-gold text-white px-6 py-2 rounded font-bold hover:bg-sienna transition">
          + إضافة لوحة جديدة
        </button>
      </div>

      {loading ? <p>جاري التحميل...</p> : (
        <div className="bg-white rounded-lg shadow overflow-x-auto">
          <table className="min-w-full divide-y">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">اللوحة</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">السعر</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الحالة</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">مميزة؟</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">إجراءات</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {paintings.map((p) => (
                <tr key={p.id}>
                  <td className="px-6 py-4 whitespace-nowrap flex items-center gap-3">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img src={p.imageUrl} className="w-12 h-12 object-cover rounded" alt="" />
                    <span className="font-medium text-ink">{p.title}</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-gray-600">${p.price}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-xs rounded ${p.isAvailable ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                      {p.isAvailable ? 'متاح' : 'مباع'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {p.isFeatured ? '⭐ نعم' : 'لا'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap space-x-2 space-x-reverse">
                    <button onClick={() => openEditModal(p)} className="text-blue-600 hover:underline text-sm">تعديل</button>
                    <button onClick={() => setDeleteId(p.id)} className="text-red-600 hover:underline text-sm">حذف</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <Modal isOpen={isEditOpen} onClose={() => setIsEditOpen(false)} title="تعديل اللوحة">
        <form onSubmit={handleUpdate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">اسم اللوحة</label>
            <input value={form.title} onChange={(e) => setForm({...form, title: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">رابط الصورة</label>
            <input value={form.imageUrl} onChange={(e) => setForm({...form, imageUrl: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">السعر</label>
            <input type="number" value={form.price} onChange={(e) => setForm({...form, price: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">الوصف</label>
            <textarea value={form.description} onChange={(e) => setForm({...form, description: e.target.value})} className="w-full p-2 border rounded" rows={3}></textarea>
          </div>
          
          <div>
            <label className="block text-sm font-medium mb-1">الحالة</label>
            <select value={form.status} onChange={(e) => setForm({...form, status: e.target.value})} className="w-full p-2 border rounded bg-white">
              <option value="available">متاح للبيع</option>
              <option value="sold">مباع</option>
            </select>
          </div>

          <label className="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked={form.isFeatured} onChange={(e) => setForm({...form, isFeatured: e.target.checked})} className="w-4 h-4" />
            <span className="text-sm">عرض كلوحة مميزة</span>
          </label>

          <button type="submit" className="w-full bg-ink text-white py-2 rounded font-bold hover:bg-gold transition">حفظ التعديلات</button>
        </form>
      </Modal>

      <Modal isOpen={isAddOpen} onClose={() => setIsAddOpen(false)} title="إضافة لوحة جديدة">
        <form onSubmit={handleAdd} className="space-y-4">
           <div>
            <label className="block text-sm font-medium mb-1">اسم اللوحة</label>
            <input value={form.title} onChange={(e) => setForm({...form, title: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">رابط الصورة</label>
            <input value={form.imageUrl} onChange={(e) => setForm({...form, imageUrl: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">السعر</label>
            <input type="number" value={form.price} onChange={(e) => setForm({...form, price: e.target.value})} className="w-full p-2 border rounded" required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">الوصف</label>
            <textarea value={form.description} onChange={(e) => setForm({...form, description: e.target.value})} className="w-full p-2 border rounded" rows={3}></textarea>
          </div>
          
          <div>
            <label className="block text-sm font-medium mb-1">الحالة</label>
            <select value={form.status} onChange={(e) => setForm({...form, status: e.target.value})} className="w-full p-2 border rounded bg-white">
              <option value="available">متاح للبيع</option>
              <option value="sold">مباع</option>
            </select>
          </div>

          <label className="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked={form.isFeatured} onChange={(e) => setForm({...form, isFeatured: e.target.checked})} className="w-4 h-4" />
            <span className="text-sm">لوحة مميزة</span>
          </label>

          <button type="submit" className="w-full bg-gold text-white py-2 rounded font-bold hover:bg-sienna transition">إضافة اللوحة</button>
        </form>
      </Modal>

      <ConfirmDialog 
        isOpen={!!deleteId} 
        onClose={() => setDeleteId(null)} 
        onConfirm={handleDelete} 
        message="هل أنت متأكد من حذف هذه اللوحة؟"
      />
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 3. إصلاح صفحة تسجيل الدخول
# ---------------------------------------------------------
cat << 'EOF' > src/app/admin/login/page.tsx
"use client";
import { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email, password);
      toast.success('مرحباً بعودتك!');
      router.push('/admin');
    } catch (error) {
      console.error(error);
      toast.error('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-paper px-4">
      <div className="bg-white p-8 rounded-lg shadow-xl max-w-md w-full border border-gold/20">
        <h1 className="text-3xl font-bold text-ink mb-2 text-center">تسجيل الدخول</h1>
        <p className="text-gray-500 text-center mb-6 text-sm">لوحة تحكم الفنان</p>
        
        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">البريد الإلكتروني</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full p-3 border rounded focus:ring-2 focus:ring-gold outline-none"
              placeholder="admin@example.com"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">كلمة المرور</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full p-3 border rounded focus:ring-2 focus:ring-gold outline-none"
              placeholder="••••••••"
              required
            />
          </div>
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-ink text-white py-3 rounded font-bold hover:bg-gold transition disabled:opacity-50"
          >
            {loading ? 'جاري الدخول...' : 'دخول'}
          </button>
        </form>
      </div>
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 4. إصلاح صفحة الإعدادات
# ---------------------------------------------------------
cat << 'EOF' > src/app/admin/settings/page.tsx
"use client";
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import toast from 'react-hot-toast';

export default function AdminSettings() {
  const [form, setForm] = useState({
    artistName: '',
    bio: '',
    profileImage: '',
    whatsapp: '',
    telegramType: 'username',
    telegramValue: '',
    facebook: '',
    instagram: '',
    youtube: '',
    tiktok: '',
    twitter: ''
  });

  useEffect(() => {
    const fetchSettings = async () => {
      const docRef = doc(db, 'settings', 'config');
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        const data = docSnap.data();
        setForm({
          artistName: data.artistName || '',
          bio: data.bio || '',
          profileImage: data.profileImage || '',
          whatsapp: data.whatsapp || '',
          telegramType: data.telegramType || 'username',
          telegramValue: data.telegramValue || '',
          facebook: data.facebook || '',
          instagram: data.instagram || '',
          youtube: data.youtube || '',
          tiktok: data.tiktok || '',
          twitter: data.twitter || ''
        });
      }
    };
    fetchSettings();
  }, []);

  const validatePhone = (phone: string) => {
    const regex = /^01[0-2,5]{1}[0-9]{8}$/;
    return regex.test(phone);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (form.whatsapp && !validatePhone(form.whatsapp)) {
      toast.error('رقم الواتساب يجب أن يكون 11 رقم ويبدأ بـ 01');
      return;
    }

    try {
      await setDoc(doc(db, 'settings', 'config'), form);
      toast.success('تم حفظ الإعدادات وتحديث الموقع بنجاح');
    } catch (err) {
      console.error(err);
      toast.error('حدث خطأ');
    }
  };

  const handleChange = (key: string, value: string) => {
    if (key === 'whatsapp' && value) {
      if (!/^\d+$/.test(value)) return;
    }
    setForm(prev => ({ ...prev, [key]: value }));
  }

  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-3xl font-bold text-ink mb-8">الإعدادات العامة</h1>
      
      <form onSubmit={handleSave} className="bg-white p-8 rounded-lg shadow space-y-6">
        
        <section>
          <h2 className="text-xl font-bold text-ink border-b pb-2 mb-4">بيانات الفنان</h2>
          <div className="grid gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">اسم الفنان</label>
              <input value={form.artistName} onChange={(e) => handleChange('artistName', e.target.value)} className="w-full p-2 border rounded" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">رابط الصورة الشخصية</label>
              <input value={form.profileImage} onChange={(e) => handleChange('profileImage', e.target.value)} className="w-full p-2 border rounded" />
              {/* eslint-disable-next-line @next/next/no-img-element */}
              {form.profileImage && <img src={form.profileImage} className="w-16 h-16 rounded-full mt-2 object-cover" alt="Profile" />}
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">نبذة شخصية</label>
              <textarea value={form.bio} onChange={(e) => handleChange('bio', e.target.value)} rows={3} className="w-full p-2 border rounded"></textarea>
            </div>
          </div>
        </section>

        <section>
          <h2 className="text-xl font-bold text-ink border-b pb-2 mb-4">وسائل التواصل</h2>
          <div className="grid gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">واتساب (11 رقم)</label>
              <input value={form.whatsapp} onChange={(e) => handleChange('whatsapp', e.target.value)} className="w-full p-2 border rounded" maxLength={11} />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">معرف التليجرام</label>
              <div className="flex items-center gap-2">
                <span className="text-gray-400 bg-gray-100 p-2 rounded border">@</span>
                <input 
                   value={form.telegramValue.replace('@', '')} 
                   onChange={(e) => handleChange('telegramValue', e.target.value)} 
                   className="w-full p-2 border rounded" 
                   placeholder="username" 
                />
              </div>
            </div>
          </div>
        </section>

        <section>
          <h2 className="text-xl font-bold text-ink border-b pb-2 mb-4">حسابات التواصل الاجتماعي</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">فيسبوك</label>
              <input value={form.facebook} onChange={(e) => handleChange('facebook', e.target.value)} className="w-full p-2 border rounded" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">انستجرام</label>
              <input value={form.instagram} onChange={(e) => handleChange('instagram', e.target.value)} className="w-full p-2 border rounded" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">يوتيوب</label>
              <input value={form.youtube} onChange={(e) => handleChange('youtube', e.target.value)} className="w-full p-2 border rounded" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">تيك توك</label>
              <input value={form.tiktok} onChange={(e) => handleChange('tiktok', e.target.value)} className="w-full p-2 border rounded" />
            </div>
             <div className="md:col-span-2">
              <label className="block text-sm font-medium mb-1">تويتر / إكس</label>
              <input value={form.twitter} onChange={(e) => handleChange('twitter', e.target.value)} className="w-full p-2 border rounded" />
            </div>
          </div>
        </section>

        <button type="submit" className="w-full bg-gold text-white py-3 rounded font-bold text-lg hover:bg-sienna transition">
          حفظ الإعدادات
        </button>
      </form>
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 5. إصلاح صفحة تفاصيل المقال
# ---------------------------------------------------------
cat << 'EOF' > src/app/blog/[id]/page.tsx
"use client";
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';

interface Post {
  id: string;
  title: string;
  content: string;
  imageUrl: string;
  date: string;
}

export default function BlogPostPage() {
  const { id } = useParams();
  const router = useRouter();
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPost = async () => {
      if (!id) return;
      const docRef = doc(db, 'blog', id as string);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setPost({ id: docSnap.id, ...docSnap.data() } as Post);
      } else {
        router.push('/blog');
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
        <Link href="/blog" className="text-gold hover:underline mb-6 inline-block flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          العودة للمدونة
        </Link>

        {post.imageUrl && (
          <div className="relative w-full h-64 md:h-96 rounded-lg overflow-hidden shadow-lg mb-8">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={post.imageUrl} alt={post.title} className="w-full h-full object-cover" />
          </div>
        )}

        <h1 className="text-4xl font-bold text-ink mb-4 leading-tight">{post.title}</h1>
        <p className="text-gray-500 text-sm mb-8 border-b pb-4">
          {new Date(post.date).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}
        </p>

        <div className="prose prose-lg max-w-none text-ink/80 whitespace-pre-line">
          {post.content}
        </div>
      </article>
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 6. إصلاح الصفحة الرئيسية (Quotes fix)
# ---------------------------------------------------------
cat << 'EOF' > src/app/page.tsx
"use client";
import Link from "next/link";
import { useSettings } from "@/context/SettingsContext";
import { usePaintings } from "@/hooks/usePaintings";
import PaintingCard from "@/components/PaintingCard";

export default function Home() {
  const { settings } = useSettings();
  const { paintings } = usePaintings();
  
  const featuredPaintings = paintings.filter(p => p.isFeatured).slice(0, 3);

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative h-[80vh] flex items-center justify-center text-center bg-gradient-to-b from-paper to-white overflow-hidden">
        <div className="absolute top-10 right-10 w-64 h-64 bg-gold/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-10 left-10 w-96 h-96 bg-sienna/10 rounded-full blur-3xl"></div>

        <div className="relative z-10 max-w-3xl mx-auto px-6 animate-fade-in">
          <h1 className="text-5xl md:text-7xl font-bold mb-6 text-ink">
            <span className="title-brush">{settings.artistName}</span>
          </h1>
          <p className="text-xl text-ink/70 mb-8 leading-relaxed">
            أرسم بالألوان الزيتية لأعبر عن صوت الروح. استكشف معرضي من اللوحات الفريدة التي تمزج بين الواقع والخيال.
          </p>
          <div className="flex justify-center gap-4">
            <Link href="/gallery" className="bg-ink text-white px-8 py-3 rounded font-bold hover:bg-gold transition duration-300 shadow-lg">
              زيارة المعرض
            </Link>
            <Link href="/about" className="border-2 border-ink text-ink px-8 py-3 rounded font-bold hover:bg-ink hover:text-white transition duration-300">
              قصتي
            </Link>
          </div>
        </div>
      </section>

      {/* Featured Section */}
      <section className="max-w-7xl mx-auto px-6 py-16">
        <h2 className="text-3xl font-bold text-center mb-12 text-ink title-brush">أعمال مميزة</h2>
        
        {featuredPaintings.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {featuredPaintings.map((painting) => (
              <PaintingCard key={painting.id} painting={painting} showStatus={false} />
            ))}
          </div>
        ) : (
          <div className="text-center text-gray-400 py-12 border-2 border-dashed border-gray-200 rounded-lg">
            <p>لم يتم تحديد لوحات مميزة بعد.</p>
            <p className="text-sm mt-2">اذهب للوحة التحكم واختر &quot;عرض في الرئيسية&quot;.</p>
          </div>
        )}
        
      </section>
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 7. إصلاح CartSidebar (Unused var)
# ---------------------------------------------------------
cat << 'EOF' > src/components/CartSidebar.tsx
"use client";
import { useCart } from '@/context/CartContext';

interface Props {
  onClose: () => void;
}

export default function CartSidebar({ onClose }: Props) {
  const { cart, removeFromCart, sendOrder, clearCart } = useCart();

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="bg-black/30 w-full absolute inset-0" onClick={onClose}></div>
      <div className="relative w-full max-w-md h-full bg-paper shadow-2xl flex flex-col animate-fade-in">
        
        {/* Header */}
        <div className="p-6 border-b border-gold/20 flex justify-between items-center">
          <h2 className="text-2xl font-bold text-ink">لوحات مختارة</h2>
          <button onClick={onClose} className="text-ink hover:text-gold text-2xl">&times;</button>
        </div>

        {/* Items List */}
        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          {cart.length === 0 ? (
            <p className="text-center text-gray-500 mt-10">لم تقم باختيار أي لوحات بعد.</p>
          ) : (
            cart.map((item) => (
              <div key={item.id} className="flex items-center justify-between bg-white p-3 rounded shadow-sm border border-gray-100">
                <div className="flex items-center gap-3">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img src={item.imageUrl} alt={item.title} className="w-12 h-12 object-cover rounded" />
                    <div>
                        <h4 className="font-bold text-ink text-sm">{item.title}</h4>
                        <p className="text-gold font-semibold text-sm">${item.price}</p>
                    </div>
                </div>
                <button onClick={() => removeFromCart(item.id)} className="text-red-400 text-xs hover:text-red-600 p-2">
                  إزالة
                </button>
              </div>
            ))
          )}
        </div>

        {/* Footer Actions */}
        {cart.length > 0 && (
          <div className="p-6 border-t border-gold/20 space-y-3 bg-white">
            
            <div className="flex gap-3">
                <button 
                    onClick={() => sendOrder('whatsapp')}
                    className="flex-1 bg-green-600 text-white py-3 rounded font-bold hover:bg-green-700 transition flex items-center justify-center gap-2"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                    واتساب
                </button>

                <button 
                    onClick={() => sendOrder('telegram')}
                    className="flex-1 bg-blue-500 text-white py-3 rounded font-bold hover:bg-blue-600 transition flex items-center justify-center gap-2"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 24 24" fill="currentColor"><path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z"/></svg>
                    تيليجرام
                </button>
            </div>

            <button onClick={clearCart} className="w-full text-gray-500 text-sm hover:underline">
              إفراغ السلة
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
EOF

# ---------------------------------------------------------
# 8. إصلاح Footer (Unused function)
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
               <a href={getWALink()} target="_blank" className="bg-paper/10 p-2 rounded hover:bg-gold transition"><svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg></a>
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

echo "✅ تم إصلاح جميع ملفات الـ TypeScript والـ ESLint."
echo "➡️ الآن قم برفع الكود إلى GitHub:"
echo "git add ."
echo "git commit -m 'fix: build errors for deployment'"
echo "git push"
