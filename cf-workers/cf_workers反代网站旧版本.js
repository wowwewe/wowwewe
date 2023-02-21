let config = {
    basic: {
    	// 替换成你想镜像的站点
        upstream: 'https://googl.com/',
        // 如果那个站点有专门的移动适配站点，否则保持和上面一致
        mobileRedirect: 'https://googl.com/'
    },

    firewall: {
        blockedRegion: [],
        blockedIPAddress: [],
        scrapeShield: true
    },

    routes: {
    },

    optimization: {
        cacheEverything: false,
        cacheTtl: 5,
        mirage: true,
        polish: 'off',
        minify: {
            javascript: true,
            css: true,
            html: true
        }
    }
}

addEventListener('fetch', event => {
    event.respondWith(fetchAndApply(event.request));
})

async function fetchAndApply(request) {
    const region = request.headers.get('cf-ipcountry');
    const ipAddress = request.headers.get('cf-connecting-ip') || '';
    const userAgent = request.headers.get('user-agent') || '';

    if (region !== '' && config.firewall.blockedRegion.includes(region.toUpperCase())) {
        return new Response(
            'Access denied: booster.js is not available in your region.',
            {
                status: 403
            }
        );
    } else if (ipAddress !== '' && config.firewall.blockedRegion.includes(ipAddress)) {
        return new Response(
            'Access denied: Your IP address is blocked by booster.js.',
            {
                status: 403
            }
        );
    }

    let requestURL = new URL(request.url);
    let upstreamURL = null;

    if (userAgent && isMobile(userAgent) === true) {
        upstreamURL = new URL(config.basic.mobileRedirect);
    } else if (region && config.routes.hasOwnProperty(region.toUpperCase())) {
        upstreamURL = new URL(config.routes[region.toUpperCase()]);
    } else {
        upstreamURL = new URL(config.basic.upstream);
    }

    requestURL.protocol = upstreamURL.protocol;
    requestURL.host = upstreamURL.host;
    requestURL.pathname = upstreamURL.pathname + requestURL.pathname;

    let fetchedResponse = await fetch(
        new Request(requestURL, {
            cf: {
                cacheEverything: config.optimization.cacheEverything,
                cacheTtl: config.optimization.cacheTtl,
                mirage: config.optimization.mirage,
                polish: config.optimization.polish,
                minify: config.optimization.minify,
                scrapeShield: config.firewall.scrapeShield
            },
            method: request.method,
            headers: request.headers,
            body: request.body
        })
    );

    let modifiedResponseHeaders = new Headers(fetchedResponse.headers);
    if (modifiedResponseHeaders.has("x-pjax-url")) {
        let pjaxURL = new URL(modifiedResponseHeaders.get("x-pjax-url"));
        pjaxURL.protocol = requestURL.protocol;
        pjaxURL.host = requestURL.host;
        pjaxURL.pathname = pjaxURL.path.replace(requestURL.pathname, '/')

        modifiedResponseHeaders.set(
            "x-pjax-url",
            pjaxURL.href
        );
    }

    return new Response(
        fetchedResponse.body,
        {
            headers: modifiedResponseHeaders,
            status: fetchedResponse.status,
            statusText: fetchedResponse.statusText
        }
    );
}

async function isMobile(userAgent) {
    console.log(userAgent)
    let agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod'];
    for (let agent of agents) {
        if (userAgent.indexOf(agent) > 0) {
            console.log(agent)
            return true;
        }
    }
    return false;
}
