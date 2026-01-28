/**
 * YouTube player 极简安全脚本（Surge）
 * 目标：
 *  - 移除播放器广告字段
 *  - 强制 playability OK（后台 / PIP）
 * 安全边界：
 *  - 无外联
 *  - 无 eval
 *  - 无 protobuf
 *  - 无参数读取
 */

let body = $response.body;
if (!body) {
  $done({});
}

let obj;
try {
  obj = JSON.parse(body);
} catch (_) {
  $done({});
}

// === 广告字段清理 ===
if (obj.adPlacements) delete obj.adPlacements;
if (obj.playerAds) delete obj.playerAds;
if (obj.adBreakHeartbeatParams) delete obj.adBreakHeartbeatParams;

// === 强制可播放 / 后台 ===
if (obj.playabilityStatus) {
  obj.playabilityStatus.status = "OK";
  delete obj.playabilityStatus.reason;
  delete obj.playabilityStatus.messages;
}

// === 去除部分限制标记 ===
if (obj.videoDetails) {
  obj.videoDetails.isLiveContent = false;
}

$done({ body: JSON.stringify(obj) });
