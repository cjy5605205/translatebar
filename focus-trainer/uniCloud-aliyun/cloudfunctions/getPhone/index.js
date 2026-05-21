'use strict'
exports.main = async (event, context) => {
  const { code } = event
  const accessToken = await getAccessToken(context)
  const res = await uniCloud.httpclient.request(
    `https://api.weixin.qq.com/wxa/business/getuserphonenumber?access_token=${accessToken}`,
    {
      method: 'POST',
      data: { code },
      dataType: 'json',
    }
  )
  return { phone: res.data.phone_info?.phoneNumber || '' }
}

async function getAccessToken(context) {
  const res = await uniCloud.httpclient.request(
    `https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=${context.APPID}&secret=${context.APPSECRET}`,
    { dataType: 'json' }
  )
  return res.data.access_token
}
