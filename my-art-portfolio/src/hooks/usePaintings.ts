import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';

interface Painting {
  id: string;
  title: string;
  description: string;
  price: number;
  imageUrl: string;
  isAvailable: boolean;
  isFeatured: boolean;
}

export const usePaintings = () => {
  const [paintings, setPaintings] = useState<Painting[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'paintings'), orderBy('createdAt', 'desc'));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const paintingsData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Painting[];
      
      setPaintings(paintingsData);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  return { paintings, loading };
};
