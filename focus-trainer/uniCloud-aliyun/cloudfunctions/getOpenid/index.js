'use strict'
exports.main = async (event, context) => {
  const { code } = event
  const res = await uniCloud.httpclient.request(
    `https://api.weixin.qq.com/sns/jscode2session?appid=${context.APPID}&secret=${context.APPSECRET}&js_code=${code}&grant_type=authorization_code`,
    { dataType: 'json' }
  )
  return { openid: res.data.openid }
}
