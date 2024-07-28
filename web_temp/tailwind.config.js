/** @type {import('tailwindcss').Config} */
export default {
	content: ['./src/**/*.{html,js,svelte,ts}'],
	theme: {
	  extend: {
		colors: {
		  peach: '#FACFAD',
		  peach2: '#F2AA7E',
		  darkGray: '#364445',
		  coklat_hover:'#5E554A'
		},
		fontFamily: {
		  body: ['Helvetica', 'Arial', 'sans-serif'],
		  poppins: ["Poppins", "sans-serif"],        
		  roboto: ["Roboto Condensed", "sans-serif"],        
		},
	  },
	},
	plugins: [],
  }
  
  