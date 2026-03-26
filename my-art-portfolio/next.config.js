/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '**' }, // السماح بجميع روابط الصور (Cloudinary وغيرها)
    ],
  },
}

module.exports = nextConfig
