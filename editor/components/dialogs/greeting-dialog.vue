<template>
  <v-dialog v-model="dialog" persistent max-width="600px">
    <v-card>
      <v-card-title>
        <span class="headline">挨拶メッセージ追加</span>
      </v-card-title>
      <v-card-text>
        <v-container>
          <v-row>
            <v-col cols="12" xs="12">
              <v-textarea v-model="start" label="開始時刻" rows="1"></v-textarea>
              <v-textarea v-model="end" label="終了時刻" rows="1"></v-textarea>
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
      start: '',
      end: '',
      messages: '',
    }
  },
  watch: {
    item: function (item) {
      if (item != null) {
        this.start = item.range.start
        this.end = item.range.end
        this.messages = item.messages.join('\n')
      } else {
        this.start = ''
        this.end = ''
        this.messages = ''
      }
    },
  },
  methods: {
    close: function () {
      this.$emit('close')
    },
    add: function () {
      const startValue = parseInt(this.start)
      const endValue = parseInt(this.end)
      if (Number.isNaN(startValue) || Number.isNaN(endValue)) {
        return
      }
      const messages = this.messages.length === 0 ? [] : this.messages.split('\n')
      const newItem = {
        range: {
          start: startValue,
          end: endValue,
        },
        messages: messages,
      }
      this.$emit('add', newItem)
      this.$emit('close')
    },
    update: function () {
      const startValue = parseInt(this.start)
      const endValue = parseInt(this.end)
      if (Number.isNaN(startValue) || Number.isNaN(endValue)) {
        return
      }
      const messages = this.messages.length === 0 ? [] : this.messages.split('\n')
      const newItem = {
        range: {
          start: startValue,
          end: endValue,
        },
        messages: messages,
      }
      this.$emit('update', this.item, newItem)
      this.$emit('close')
    },
  },
}
</script>
