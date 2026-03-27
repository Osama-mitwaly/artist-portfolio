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
