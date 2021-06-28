import productionConfig from '../Config/production/config.json'
import developmentConfig from '../Config/development/config.json'

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
    title: process.env.NODE_ENV !== 'production' ? developmentConfig.bot.name : productionConfig.bot.name,
    meta: [{ charset: 'utf-8' }, { name: 'viewport', content: 'width=device-width, initial-scale=1' }],
  },
  vuetify: {
    theme: {
      themes: {
        light: {
          background: '#eeeeee'
        },
      },
    },
  },
  axios: {
    baseURL: process.env.NODE_ENV !== 'production' ? 'http://localhost:8080/api/v1' : '/api/v1',
    credentials: true
  },
  publicRuntimeConfig: {
    isDevelopment: process.env.NODE_ENV !== 'production',
    wsOrigin: process.env.NODE_ENV !== 'production' ? developmentConfig.server.wsOrigin : productionConfig.server.wsOrigin,
  }
}
