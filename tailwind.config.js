/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./views/**/*.{html,js}"],
  theme: {
    extend: {
      colors: {
        'irish-coffee': {
          '50': '#f8f6ee',
          '100': '#efead2',
          '200': '#e0d5a8',
          '300': '#cdb977',
          '400': '#bea051',
          '500': '#af8d43',
          '600': '#967138',
          '700': '#79552f',
          '800': '#63452c',
          '900': '#583d2b',
          '950': '#322016',
      },
    
      }
    }
  },
  plugins: [],
}

