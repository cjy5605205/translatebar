import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const openid = ref('')
  const nickname = ref('')
  const avatar = ref('')
  const phone = ref('')

  const isLogin = computed(() => !!openid.value)

  async function login() {
    return new Promise<void>((resolve) => {
      uni.login({
        provider: 'weixin',
        success: async (res) => {
          try {
            const result = await uniCloud.callFunction({
              name: 'getOpenid',
              data: { code: res.code },
            })
            const data = result.result as any
            openid.value = data.openid
            await syncUserInfo()
            resolve()
          } catch {
            resolve()
          }
        },
        fail: () => resolve(),
      })
    })
  }

  async function loginByPhone(e: any) {
    const { code } = e.detail
    try {
      const result = await uniCloud.callFunction({
        name: 'getPhone',
        data: { code },
      })
      const data = result.result as any
      if (data.phone) {
        phone.value = data.phone
      }
    } catch {
      // phone login failed silently
    }
  }

  function syncUserInfo() {
    return new Promise<void>((resolve) => {
      uni.getUserInfo({
        success: (res) => {
          nickname.value = res.userInfo.nickName
          avatar.value = res.userInfo.avatarUrl
          resolve()
        },
        fail: () => resolve(),
      })
    })
  }

  function logout() {
    openid.value = ''
    nickname.value = ''
    avatar.value = ''
    phone.value = ''
  }

  return { openid, nickname, avatar, phone, isLogin, login, loginByPhone, logout }
})
