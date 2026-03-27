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
