let header = $request.headers;
header['x-forwarded-for'] = '8.8.8.8';
header['user-agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57';
$done({headers: header});