// Generated by ChinaIP2PAC
// https://github.com/dodowhat/ChinaIP2PAC

var chinaIP = __IPLIST__;

var proxy = "__PROXY__";

var direct = 'DIRECT;';

function FindProxyForURL(url, host) {
    for (var i = 0; i < chinaIP.length; i++) {
        if (isInNet(host, chinaIP[i][0], chinaIP[i][1])) {
            return direct;
        }
    }
    return proxy;
}
