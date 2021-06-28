<template>
  <v-app>
    <v-navigation-drawer v-model="drawer" fixed app>
      <v-list class="navigation-list">
        <v-list-item class="accent navigation-list-header">
          <v-list-item-content>
            <v-list-item-title class="font-weight-bold text-center text-h4 white--text">Editor</v-list-item-title>
          </v-list-item-content>
        </v-list-item>

        <v-divider></v-divider>

        <NuxtLink class="text-decoration-none" to="/">
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title class="text-body-1 font-weight-medium text-center primary--text">会話</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </NuxtLink>

        <NuxtLink class="text-decoration-none" to="/greeting">
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title class="text-body-1 font-weight-medium text-center primary--text">挨拶</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </NuxtLink>

        <NuxtLink class="text-decoration-none" to="/badword">
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title class="text-body-1 font-weight-medium text-center primary--text">BADワード</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </NuxtLink>

        <NuxtLink class="text-decoration-none" to="/fallback">
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title class="text-body-1 font-weight-medium text-center primary--text">フォールバック</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </NuxtLink>

        <NuxtLink class="text-decoration-none" to="/leave">
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title class="text-body-1 font-weight-medium text-center primary--text">退室</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </NuxtLink>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <v-container fluid fill-height>
        <NuxtChild />
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
export default {
  data() {
    return {
      drawer: null,
    }
  },
}
</script>

<style scoped>
.navigation-list {
  padding: unset;
}
.navigation-list-header.v-list-item {
  height: 64px;
}
.navigation-list-item.v-list-item {
  height: 44px;
}
</style>
