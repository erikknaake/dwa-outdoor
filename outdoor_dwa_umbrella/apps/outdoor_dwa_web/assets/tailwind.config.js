module.exports = {
  purge: [],
  darkMode: false,//or 'media' or 'class'
  theme: {
    extend: {},
    minHeight: {
      '0': '0',

      '48': '12rem',

      '1/4': '25vh',

      '1/2': '50vh',

      '3/4': '75vh',

      'full': '100%',
    },
    maxWidth: {
      '0': '0',
      '8': '8rem',

      '1/5' : '20%',

      '1/4': '25%',

      '1/2': '50%',

      '3/4': '75%',

      'full': '100%',
    },
    fontFamily: {
      sans: [
        // "system-ui",
        "-apple-system",
        // "BlinkMacSystemFont",
        "Segoe UI",
        "Roboto",
        "Helvetica Neue",
        "Arial",
        "Noto Sans",
        "sans-serif",
        "Apple Color Emoji",
        "Segoe UI Emoji",
        "Segoe UI Symbol",
        "Noto Color Emoji",
      ],
    },
    minWidth: {
      '700': '700px',
    }
  },
  variants: {
    extend: {}
  },
  plugins: [require("@tailwindcss/ui")],
  future: {
  },
};
