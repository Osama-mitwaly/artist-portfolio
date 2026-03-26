// إعدادات الموقع - سيتم ربطها لاحقاً بـ Firebase لتعديلها من لوحة التحكم
export const siteConfig = {
  artistName: "عبد الرحمن ناقشني",
  whatsappNumber: "201234567890", // استبدل برقمك الحقيقي لاحقاً
  telegramUsername: "artist_telegram", // استبدل باسم المستخدم
  socialLinks: {
    facebook: "https://facebook.com/artist",
    instagram: "https://instagram.com/artist",
    youtube: "https://youtube.com/artist",
    tiktok: "https://tiktok.com/@artist",
    twitter: "https://twitter.com/artist",
  },
  messages: {
    whatsappWelcome: "مرحباً عبد الرحمن، أنا مهتم بشراء اللوحات التالية:",
    telegramWelcome: "مرحباً، أود الاستفسار عن اللوحات التالية:",
    singleItemInquiry: "مرحباً، أنا مهتم باللوحة: " // سيتم إضافة اسم اللوحة تلقائياً
  }
};
