<template>
  <v-dialog v-model="dialog" persistent max-width="600px">
    <v-card>
      <v-card-title>
        <span class="headline">フォールバックワード追加</span>
      </v-card-title>
      <v-card-text>
        <v-container>
          <v-row>
            <v-col cols="12" xs="12">
              <v-textarea v-model="messageValue" label="メッセージ" rows="1"></v-textarea>
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
      messageValue: '',
    }
  },
  watch: {
    item: function (item) {
      if (item != null) {
        this.messageValue = item.message
      } else {
        this.messageValue = ''
      }
    },
  },
  methods: {
    close: function () {
      this.$emit('close')
    },
    add: function () {
      const newItem = {
        message: this.messageValue,
      }
      this.$emit('add', newItem)
      this.$emit('close')
    },
    update: function () {
      const newItem = {
        message: this.messageValue,
      }
      this.$emit('update', this.item, newItem)
      this.$emit('close')
    },
  },
}
</script>
