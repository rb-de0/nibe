<template>
  <v-container fluid fill-height class="flex-column align-content-start">
    <Dialog :dialog="dialog" :item="dialogTargetItem" @close="closeDialog" @add="add" @update="update"></Dialog>
    <v-snackbar v-model="saveErrorSnackBar" color="error" :timeout="1000">保存に失敗しました</v-snackbar>
    <v-snackbar v-model="saveSnackBar" color="accent" :timeout="1000">保存しました</v-snackbar>
    <div class="width-100">
      <div class="d-flex justify-end">
        <v-btn color="accent" dark class="mx-1" @click="openCreateDialog">追加</v-btn>
        <v-btn color="blue" dark class="mx-1" :loading="saving" @click="save">保存</v-btn>
      </div>
      <v-text-field class="mb-4" v-model="search" append-icon="mdi-magnify" label="検索" single-line hide-details></v-text-field>
      <v-data-table disable-sort hide-default-footer :page.sync="page" :items-per-page="30" :headers="headers" :search="search" :items="items" item-key="id" class="elevation-1">
        <template v-slot:body="{ items }">
          <tbody>
            <tr v-for="item in items" :key="item.id">
              <td>
                <div class="py-2">
                  {{ item.message }}
                </div>
              </td>
              <td>
                <div class="d-flex">
                  <v-icon small class="mr-2" @click="openEditDialog(item)">mdi-pencil</v-icon>
                  <v-icon small class="mr-2" @click="deleteItem(item)">mdi-delete</v-icon>
                </div>
              </td>
            </tr>
          </tbody>
        </template>
      </v-data-table>
      <v-pagination color="accent" v-model="page" :length="pageCount"></v-pagination>
    </div>
  </v-container>
</template>

<script>
import Dialog from '~/components/dialogs/fallback-dialog.vue'
import { v4 as uuidv4 } from 'uuid'

export default {
  components: {
    Dialog,
  },
  data() {
    return {
      saving: false,
      search: '',
      items: [],
      page: 1,
      pageCount: 0,
      headers: [
        { text: 'メッセージ', value: 'messages' },
        { text: '編集', value: 'edit', width: '10%' },
      ],
      dialog: false,
      dialogTargetItem: null,
      saveSnackBar: false,
      saveErrorSnackBar: false,
    }
  },
  head() {
    return {
      title: 'フォールバックワード',
    }
  },
  mounted() {
    this.$axios
      .get('/dictionaries', {
        params: {
          name: 'fallback',
        },
      })
      .then((r) => {
        this.items = r.data.messages.map((message) => {
          return {
            id: uuidv4(),
            message: message,
          }
        })
        const pages = Math.floor((this.items.length - 1) / 30)
        this.pageCount = this.items.length !== 0 ? pages + 1 : 0
      })
  },
  methods: {
    add: function (item) {
      item.id = uuidv4()
      this.items.push(item)
      const pages = Math.floor((this.items.length - 1) / 30)
      this.pageCount = this.items.length !== 0 ? pages + 1 : 0
    },
    update: function (item, newItem) {
      newItem.id = item.id
      this.$set(this.items, this.items.indexOf(item), newItem)
    },
    deleteItem: function (item) {
      this.items.splice(this.items.indexOf(item), 1)
    },
    openCreateDialog: function () {
      this.dialogTargetItem = null
      this.dialog = true
    },
    openEditDialog: function (item) {
      this.dialogTargetItem = item
      this.dialog = true
    },
    closeDialog: function () {
      this.dialog = false
      this.dialogTargetItem = null
    },
    save: function () {
      const messages = this.items.map((r) => {
        return r.message
      })
      this.saving = true
      this.$axios
        .post(`dictionaries`, {
          name: 'fallback',
          data: {
            messages: messages,
          },
        })
        .then((_) => {
          this.saving = false
          this.saveSnackBar = true
        })
        .catch((_) => {
          this.saving = false
          this.saveErrorSnackBar = true
        })
    },
  },
}
</script>
