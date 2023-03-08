// 获取请求头
let header = $request.headers;

// 修改 x-forwarded-for 参数值，如果失效替换其他国外ip尝试
header['x-forwarded-for'] = '8.8.8.8';

// 修改 user-agent 参数值，如果失效去找最新的edge user-agent替换
header['user-agent'] = 'Mozilla/5.0 (Linux; Android 11; V2072A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36 EdgA/112.0.1696.0';

// 返回修改后的请求头
$done({headers: header});
