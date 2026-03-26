"use client";
import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { doc, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';

// الشكل الافتراضي للإعدادات
const defaultSettings = {
  artistName: "عبد الرحمن ناقشني",
  bio: "فنان تشكيلي",
  profileImage: "",
  whatsapp: "201234567890",
  telegramType: "username", // username or phone
  telegramValue: "artist_telegram",
  facebook: "#",
  instagram: "#",
  youtube: "#",
  tiktok: "#",
  twitter: "#"
};

interface SettingsType {
  artistName: string;
  bio: string;
  profileImage: string;
  whatsapp: string;
  telegramType: string;
  telegramValue: string;
  facebook: string;
  instagram: string;
  youtube: string;
  tiktok: string;
  twitter: string;
}

interface SettingsContextType {
  settings: SettingsType;
  loading: boolean;
}

const SettingsContext = createContext<SettingsContextType>({
  settings: defaultSettings,
  loading: true
});

export const SettingsProvider = ({ children }: { children: ReactNode }) => {
  const [settings, setSettings] = useState<SettingsType>(defaultSettings);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // جلب الإعدادات من Firebase في الوقت الحقيقي
    const unsub = onSnapshot(doc(db, 'settings', 'config'), (doc) => {
      if (doc.exists()) {
        setSettings(doc.data() as SettingsType);
      }
      setLoading(false);
    });

    return () => unsub();
  }, []);

  return (
    <SettingsContext.Provider value={{ settings, loading }}>
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = () => useContext(SettingsContext);
