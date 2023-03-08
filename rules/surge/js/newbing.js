// 获取请求头
let header = $request.headers;

// 修改 x-forwarded-for 参数值 如果失效替换其他国外ip尝试
header['x-forwarded-for'] = '8.8.8.8';

// 修改 user-agent 参数值 如果失效去找最新的edge user-agent替换
header['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57';

// 返回修改后的请求头
$done({headers: header});
