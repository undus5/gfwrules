// Generated by https://github.com/dodowhat/china-ip-rules

var FindProxyForURL = function(init, profiles) {
    return function(url, host) {
        "use strict";
        var result = init, scheme = url.substr(0, url.indexOf(":"));
        do {
            result = profiles[result];
            if (typeof result === "function") result = result(url, host, scheme);
        } while (typeof result !== "string" || result.charCodeAt(0) === 43);
        return result;
    };
}("+p", {
    "+p": function() {
        ;

var ipList = __IP_LIST__;

function FindProxyForURL(url, host) {
    for (var i = 0; i < ipList.length; i++) {
        if (isInNet(host, ipList[i][0], ipList[i][1])) {
            return 'DIRECT';
        }
    }
    return 'SOCKS5 127.0.0.1:1080';
}

/* End of PAC */;
        return FindProxyForURL;
    }.call(this)
});
