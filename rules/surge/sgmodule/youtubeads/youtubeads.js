// == 极简 YouTube 去广告 + 后台播放 ==
// 安全目标：只改 player 响应，不外联、不解码、不注入

let body = $response.body;
if (!body) $done({});

let obj;
try {
  obj = JSON.parse(body);
} catch (e) {
  $done({});
}

// 1️⃣ 删除广告相关字段
if (obj.adPlacements) delete obj.adPlacements;
if (obj.playerAds) delete obj.playerAds;
if (obj.adBreakHeartbeatParams) delete obj.adBreakHeartbeatParams;

// 2️⃣ 强制后台 / PIP
if (obj.playabilityStatus) {
  obj.playabilityStatus.status = "OK";
  delete obj.playabilityStatus.reason;
}

// 3️⃣ 移除播放限制
if (obj.videoDetails) {
  obj.videoDetails.isLiveContent = false;
}

$done({ body: JSON.stringify(obj) });
