export default {
  ssr: false,
  buildModules: [['@nuxtjs/vuetify']],
  modules: ['@nuxtjs/axios'],
  build: {
    babel: {
      plugins: [
        ['@babel/plugin-proposal-class-properties', { loose: true }],
        ['@babel/plugin-proposal-private-methods', { loose: true }],
      ],
    },
  },
  head: {
    meta: [{ charset: 'utf-8' }, { name: 'viewport', content: 'width=device-width, initial-scale=1' }],
  },
  vuetify: {
    theme: {
      themes: {
        light: {
          primary: '#616161',
          accent: '#009688',
        }
      }
    }
  },
  axios: {
    baseURL: '/api',
    credentials: true
  },
  serverMiddleware: ['~/api/index.js']
}
