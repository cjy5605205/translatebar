<script setup lang="ts">
import { onLaunch, onShow, onHide } from "@dcloudio/uni-app";

onLaunch(async () => {
  console.log("App Launch");
  // 静默登录
  const { useUserStore } = await import('@/stores/user')
  const userStore = useUserStore()
  try {
    await userStore.login()
  } catch {
    // 静默登录失败，用户可稍后手动登录
  }
});

onShow(() => {
  console.log("App Show");
});

onHide(() => {
  console.log("App Hide");
});
</script>
<style></style>
