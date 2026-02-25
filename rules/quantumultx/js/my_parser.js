/**
 * Quantumult X 规则转换解析器 (v3 - 支持 no-resolve 移动)
 * 逻辑：
 * 1. 转换 DOMAIN -> host 等指令。
 * 2. 强制添加 , reject。
 * 3. 检查原规则是否有 no-resolve，如果有，则追加到 reject 后面。
 */

let content = $resource.content;

if (!content) {
    $done({});
} else {
    const lines = content.split(/\r?\n/);
    const result = lines.map(line => {
        let trimLine = line.trim();

        // 1. 跳过注释和空行
        if (!trimLine || trimLine.startsWith("#") || trimLine.startsWith(";")) {
            return line;
        }

        // 2. 将整行按逗号分割并清理空格
        let parts = trimLine.split(",").map(p => p.trim());
        
        let cmd = parts[0].toUpperCase();
        let val = parts[1]; // 域名或关键字
        
        // 3. 检查原始规则中是否存在 no-resolve (不区分大小写)
        const hasNoResolve = parts.some(p => p.toLowerCase() === "no-resolve");

        // 4. 定义指令映射
        const cmdMap = {
            "DOMAIN": "host",
            "DOMAIN-SUFFIX": "host-suffix",
            "DOMAIN-KEYWORD": "host-keyword"
        };

        // 5. 如果匹配到目标指令，开始重组
        if (cmdMap[cmd]) {
            let newLine = `${cmdMap[cmd]}, ${val}, reject`;
            
            // 如果原来有 no-resolve，将其补在 reject 后面
            if (hasNoResolve) {
                newLine += ", no-resolve";
            }
            return newLine;
        }

        // 6. 其他不匹配的行（如 IP-CIDR）原样返回
        return line;
    });

    $done({ content: result.join("\n") });
}
