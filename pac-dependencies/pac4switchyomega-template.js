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

var chinaIP = __IPLIST__;

function FindProxyForURL(url, host) {
    for (var i = 0; i < chinaIP.length; i++) {
        if (isInNet(host, chinaIP[i][0], chinaIP[i][1])) {
            return 'DIRECT';
        }
        return 'SOCKS5 __LOCAL_ADDRESS__:__LOCAL_PORT__';
    }
}

/* End of PAC */;
        return FindProxyForURL;
    }.call(this)
});
