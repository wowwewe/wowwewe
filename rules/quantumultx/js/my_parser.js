/**
 * 极简 Surge 转 QX 拒绝规则解析器
 * 功能：
 * 1. DOMAIN -> host
 * 2. DOMAIN-SUFFIX -> host-suffix
 * 3. DOMAIN-KEYWORD -> host-keyword
 * 4. 每一行末尾添加 , reject
 */

function main() {
    let body = $resource.content;
    if (!body) $done({});

    let lines = body.split(/\r?\n/);
    let newLines = lines.map(line => {
        line = line.trim();
        
        // 跳过空行和注释行
        if (!line || line.startsWith("#") || line.startsWith(";")) {
            return line;
        }

        // 统一转为小写处理，方便匹配
        let lowerLine = line.toLowerCase();

        // 检查是否包含目标指令
        if (lowerLine.startsWith("domain-suffix") || 
            lowerLine.startsWith("domain") || 
            lowerLine.startsWith("domain-keyword")) {
            
            // 1. 替换指令名称 (Surge 到 QX)
            let processed = line
                .replace(/DOMAIN-SUFFIX/gi, "host-suffix")
                .replace(/DOMAIN-KEYWORD/gi, "host-keyword")
                .replace(/DOMAIN/gi, "host");

            // 2. 移除原有的策略（如果有的话，比如原来的 ,DIRECT 或 ,Proxy）
            // 这里假设原格式是 DOMAIN-SUFFIX,example.com,POLICY
            let parts = processed.split(",");
            let mainPart = parts[0]; // 指令
            let domainPart = parts[1]; // 域名内容
            
            if (mainPart && domainPart) {
                return `${mainPart.trim()},${domainPart.trim()}, reject`;
            }
        }
        
        return line; // 不匹配的行原样返回
    });

    $done({ content: newLines.join("\n") });
}

main();
