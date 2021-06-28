<template>
  <Nuxt />
</template>

<style>
.container.app-container {
  width: 360px;
  height: 270px;
}
.content-container {
  background-color: white;
  position: relative;
  overflow: hidden;
}
.visual-container {
  height: calc(100% - 48px);
}
.input-container {
  background: rgba(238, 238, 238);
  height: 56px;
  z-index: 1;
}
.v-application .message {
  font-size: 12px;
}
@media screen and (min-width: 960px) {
  .container.app-container {
    width: 640px;
    height: 480px;
  }
  .v-application .message {
    font-size: 16px;
  }
}
@media screen and (min-width: 1264px) {
  .container.app-container {
    width: 960px;
    height: 720px;
  }
  .v-application .message {
    font-size: 20px;
  }
}
.character {
  position: absolute;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
}
.character-img {
  max-height: 130%;
}
.message-window {
  background: rgba(238, 238, 238, 0.75);
  height: 30%;
  z-index: 1;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter,
.fade-leave-to {
  opacity: 0;
}
.width-100 {
  width: 100%;
}
.height-100 {
  height: 100%;
}
.scrollable {
  overflow-y: scroll;
  -ms-overflow-style: none;
  scrollbar-width: none;
}
.scrollable::-webkit-scrollbar {
  display: none;
}
.v-ripple__container {
  display: none !important;
}
</style>
