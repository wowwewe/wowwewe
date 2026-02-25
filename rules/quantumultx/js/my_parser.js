/**
 * Quantumult X 纯净版 Surge 规则转换器 (防冗余优化版)
 * * 逻辑说明：
 * 1. 强制 reject。
 * 2. 针对 ip-cidr, ip-cidr6, ip-asn：统一添加且仅添加一个 no-resolve。
 * 3. 针对 geoip, host, user-agent：绝对不带 no-resolve。
 * 4. 采用“销毁重建”机制，彻底杜绝出现 no-resolve, no-resolve 的情况。
 */

let content = $resource.content;

if (!content) {
    $done({});
} else {
    const lines = content.split(/\r?\n/);
    const result = [];

    for (let line of lines) {
        let trimLine = line.trim();

        // 1. 跳过注释、空行和段落头部
        if (!trimLine || /^[#;\/\[]/.test(trimLine)) {
            if (!trimLine.startsWith("[")) result.push(line);
            continue;
        }

        // 2. 解析原始字段
        let parts = trimLine.split(",").map(p => p.trim());
        if (parts.length < 2) {
            result.push(line);
            continue;
        }

        let cmd = parts[0].toUpperCase();
        let val = parts[1]; // 核心匹配值

        // 3. 定义 QX 标准指令映射
        const cmdMap = {
            "DOMAIN": "host",
            "DOMAIN-SUFFIX": "host-suffix",
            "DOMAIN-KEYWORD": "host-keyword",
            "IP-CIDR": "ip-cidr",
            "IP-CIDR6": "ip-cidr6",
            "IP6-CIDR": "ip-cidr6",
            "GEOIP": "geoip",
            "IP-ASN": "ip-asn",
            "USER-AGENT": "user-agent"
        };

        let targetCmd = cmdMap[cmd] || cmd.toLowerCase();

        // 4. 判断该类型是否“有权”拥有 no-resolve
        // 根据 Quantumult X 文档，只有 ip-cidr(6) 和 ip-asn 适合加 no-resolve
        const canHaveNoResolve = targetCmd.startsWith("ip-cidr") || targetCmd === "ip-asn";

        // 5. 销毁重建：忽略原有的所有后缀，只取指令和值，加上强制的 reject
        let finalRule = `${targetCmd}, ${val}, reject`;

        // 6. 如果符合条件，则追加唯一的一个 no-resolve
        if (canHaveNoResolve) {
            finalRule += ", no-resolve";
        }

        result.push(finalRule);
    }

    $done({ content: result.join("\n") });
}
