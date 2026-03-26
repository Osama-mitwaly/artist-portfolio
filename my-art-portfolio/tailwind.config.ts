import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // ألوان مستوحاة من اللوحات الزيتية
        canvas: "#FDFCF8", // خلفية الكانفاس
        paper: "#F5F1E8", // ورق دافئ
        ink: "#2C1810", // حبر داكن (بني غامق)
        gold: "#C5A059", // ذهبي
        sienna: "#A0522D", // سيينا (بني محروق)
        emerald: "#115E59", // أخضر داكن للفلوس
      },
      fontFamily: {
        cairo: ['Cairo', 'sans-serif'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
};
export default config;
