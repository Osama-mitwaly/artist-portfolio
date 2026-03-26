export interface Painting {
  id: string;
  title: string;
  description: string;
  price: number;
  imageUrl: string;
  isFeatured: boolean;
  isAvailable: boolean;
}

export interface Artist {
  name: string;
  bio: string;
  imageUrl: string;
}

export interface BlogPost {
  id: string;
  title: string;
  content: string;
  imageUrl: string;
  date: string;
}
