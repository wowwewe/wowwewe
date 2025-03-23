let ipApiUrl = "https://ip-api.com/json";
let ipIpUrl = "https://myip.ipip.net";

// 获取 ip-api 的信息
function getIpApiInfo(callback) {
  $httpClient.get(ipApiUrl, function(error, response, data) {
    if (error) {
      console.error("IP-API 请求失败:", error);
      return;
    }
    let jsonData = JSON.parse(data);
    let ip = jsonData.query;
    let country = jsonData.country;
    let countryCode = jsonData.countryCode;
    let city = jsonData.city;
    let isp = jsonData.isp;
    let emoji = getFlagEmoji(countryCode);
    callback(null, { ip, country, countryCode, city, isp, emoji });
  });
}

// 获取 myip.ipip.net 的信息
function getIpIpInfo(callback) {
  $httpClient.get(ipIpUrl, function(error, response, data) {
    if (error) {
      console.error("myip.ipip.net 请求失败:", error);
      return;
    }
    let ipPattern = /IP地址：([\d\.]+)/;
    let countryPattern = /来自：(.+?)\n/;
    let cityPattern = /位置：(.+?)\n/;
    
    let ipMatch = data.match(ipPattern);
    let countryMatch = data.match(countryPattern);
    let cityMatch = data.match(cityPattern);
    
    if (ipMatch && countryMatch && cityMatch) {
      let ip = ipMatch[1];
      let country = countryMatch[1].split(' ')[0];
      let city = cityMatch[1];
      callback(null, { ip, country, city, isp: '未知', emoji: '' });
    } else {
      callback("myip.ipip.net 数据解析失败");
    }
  });
}

// 处理并展示信息
function showInfo() {
  getIpApiInfo(function(error, ipApiData) {
    if (error) {
      console.log("获取 ip-api 数据失败:", error);
    } else {
      console.log("IP-API 数据:", ipApiData);
      // 构建显示内容
      let body = {
        title: "IP 信息（ip-api）",
        content: `IP信息：${ipApiData.ip}\n运营商：${ipApiData.isp}\n所在地：${ipApiData.emoji}${ipApiData.country} - ${ipApiData.city}`,
        icon: "globe.asia.australia.fill"
      };
      $done(body);
    }
  });

  getIpIpInfo(function(error, ipIpData) {
    if (error) {
      console.log("获取 myip.ipip.net 数据失败:", error);
    } else {
      console.log("myip.ipip.net 数据:", ipIpData);
      // 构建显示内容
      let body = {
        title: "IP 信息（myip.ipip.net）",
        content: `IP信息：${ipIpData.ip}\n所在地：${ipIpData.country} - ${ipIpData.city}`,
        icon: "globe.asia.australia.fill"
      };
      $done(body);
    }
  });
}

// 获取国旗 emoji
function getFlagEmoji(countryCode) {
  if (countryCode.toUpperCase() == 'TW') {
    countryCode = 'CN';
  }
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map(char => 127397 + char.charCodeAt())
  return String.fromCodePoint(...codePoints)
}

showInfo();
