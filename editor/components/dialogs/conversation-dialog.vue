<template>
  <v-dialog v-model="dialog" persistent max-width="600px">
    <v-card>
      <v-card-title>
        <span class="headline">会話辞書追加</span>
      </v-card-title>
      <v-card-text>
        <v-container>
          <v-row>
            <v-col cols="12" xs="12">
              <v-textarea v-model="patterns" label="パターン" rows="3"></v-textarea>
              <v-textarea v-model="synsets" label="概念" rows="3"></v-textarea>
              <v-textarea v-model="textContains" label="テキスト" rows="3"></v-textarea>
              <v-textarea v-model="messages" label="メッセージ" rows="3"></v-textarea>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="blue darken-1" text @click="close">キャンセル</v-btn>
        <v-btn v-if="item == null" color="blue darken-1" text @click="add">追加</v-btn>
        <v-btn v-if="item != null" color="blue darken-1" text @click="update">更新</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  props: {
    dialog: Boolean,
    item: Object,
  },
  data() {
    return {
      patterns: '',
      synsets: '',
      textContains: '',
      messages: '',
    }
  },
  watch: {
    item: function (item) {
      if (item != null) {
        this.patterns = item.patterns.map((p) => {
          return p.join(',')
        })
        this.synsets = item.synsets.join('\n')
        this.textContains = item.textContains.join('\n')
        this.messages = item.messages.join('\n')
      } else {
        this.patterns = ''
        this.synsets = ''
        this.textContains = ''
        this.messages = ''
      }
    },
  },
  methods: {
    close: function () {
      this.$emit('close')
    },
    add: function () {
      const patterns =
        this.patterns.length === 0
          ? []
          : this.patterns.split('\n').map((l) => {
              return l.split(',')
            })
      const synsets = this.synsets.length === 0 ? [] : this.synsets.split('\n')
      const textContains = this.textContains.length === 0 ? [] : this.textContains.split('\n')
      const messages = this.messages.length === 0 ? [] : this.messages.split('\n')
      const newItem = {
        patterns: patterns,
        synsets: synsets,
        textContains: textContains,
        messages: messages,
      }
      this.$emit('add', newItem)
      this.$emit('close')
    },
    update: function () {
      const patterns =
        this.patterns.length === 0
          ? []
          : this.patterns.split('\n').map((l) => {
              return l.split(',')
            })
      const synsets = this.synsets.length === 0 ? [] : this.synsets.split('\n')
      const textContains = this.textContains.length === 0 ? [] : this.textContains.split('\n')
      const messages = this.messages.length === 0 ? [] : this.messages.split('\n')
      const newItem = {
        patterns: patterns,
        synsets: synsets,
        textContains: textContains,
        messages: messages,
      }
      this.$emit('update', this.item, newItem)
      this.$emit('close')
    },
  },
}
</script>
