<template>
  <v-app>
    <v-main>
      <v-container fluid fill-height class="align-md-center">
        <v-container :style="{ background: $vuetify.theme.themes.light.background }" class="app-container">
          <div class="d-flex content-container flex-column height-100 width-100">
            <div class="d-flex align-end visual-container width-100 mx-0">
              <transition name="fade">
                <div v-if="isSessionActive" class="d-flex align-start justify-center character">
                  <img class="character-img" src="~/assets/character.png" />
                </div>
              </transition>
              <div class="message-window width-100 scrollable ma-1">
                <v-list dense color="transparent" class="py-1">
                  <div v-for="message in chatMessages" :key="message.messageID" class="px-2 py-1 message">
                    <div v-if="!message.isMine" class="d-flex">
                      <div>{{ message.name }} &gt;</div>
                      <div class="ml-1">{{ message.message }}</div>
                    </div>
                    <div v-if="message.isMine">
                      <div>{{ message.message }}</div>
                    </div>
                  </div>
                </v-list>
              </div>
            </div>
            <div class="input-container d-flex width-100 align-end">
              <v-text-field elevation="0" background-color="white" class="mr-2" label="発言" hide-details solo flat v-model="chatText" @keydown.enter="enterKeyDown"></v-text-field>
              <v-btn color="white" elevation="0" height="48" @click="sendChat">送信</v-btn>
            </div>
          </div>
        </v-container>
        <footer class="d-flex flex-column align-center width-100">
          <div v-if="isDevelopment">
            <DevFooter />
          </div>
          <div v-if="!isDevelopment">
            <ProdFooter />
          </div>
        </footer>
        <v-snackbar v-model="webSocketConnectionError" color="error" :timeout="5000">接続に失敗しました 時間を空けてからページを開き直してください</v-snackbar>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import DevFooter from '~/components/development/footer.vue'
import ProdFooter from '~/components/production/footer.vue'

export default {
  components: {
    DevFooter,
    ProdFooter,
  },
  data() {
    return {
      socket: null,
      chatText: '',
      chatMessages: [],
      isSessionActive: true,
      isDevelopment: true,
      wsOrigin: '',
      webSocketConnectionError: false,
    }
  },
  mounted() {
    this.isDevelopment = this.$config.isDevelopment
    this.wsOrigin = this.$config.wsOrigin
    this.createTicket()
  },
  methods: {
    async createTicket() {
      try {
        const csrfResponse = await this.$axios.get('/csrf')
        const token = csrfResponse.data.token
        const ticketResponse = await this.$axios.post('/tickets', {
          csrfToken: token,
        })
        const ticket = ticketResponse.data.token
        this.socket = new WebSocket(`${this.wsOrigin}/websocket?ticket=${ticket}`)
        this.bindSocket()
      } catch {
        this.webSocketConnectionError = true
      }
    },
    sendChat() {
      if (this.socket == null) {
        return
      }
      if (this.chatText.length <= 0) {
        return
      }
      const message = {
        type: 'chat',
        message: this.chatText,
      }
      this.chatText = ''
      this.socket.send(JSON.stringify(message))
    },
    enterKeyDown(event) {
      if (event.keyCode !== 13) return
      this.sendChat()
    },
    bindSocket() {
      if (this.socket == null) {
        return
      }
      this.socket.onmessage = (message) => {
        const messageData = JSON.parse(message.data)
        if (messageData.isListItem === true) {
          this.chatMessages.unshift(messageData)
        }
        if (messageData.type === 'leave') {
          this.isSessionActive = false
        }
      }
      this.socket.onerror = (error) => {
        this.webSocketConnectionError = true
      }
    },
  },
}
</script>

<style>
footer {
  position: absolute;
  bottom: 16px;
}
footer a {
  text-decoration: none;
}
</style>
