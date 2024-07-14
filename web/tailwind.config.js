/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        peach: '#F6D2A0', // Customize this color
        darkGray: '#394046', // Customize this color
      },
      fontFamily: {
        
        body: ['Helvetica', 'Arial', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

