(async()=>{

const pages = {
    '^https:\\/\\/steamcommunity\\.com\\/((id\\/.*$)|(profiles\\/[0-9]+.*$))':
        'profile',
    '^https:\\/\\/steamcommunity\\.com\\/(sharedfiles|workshop)\\/edititem\\/767\\/3((\\/)|(.*))':
        'upload',
    '^https:\\/\\/store.steampowered.com\\/points((\\/)|(.*))':
        'points_bg',
    '^https://steamcommunity.com/market/listings/753/.*':
        'market'
};

try
{
    const a=document.createElement('script')
    Object.getOwnPropertyNames(pages).some(_=>RegExp(_).test(location.href)?!!(a.src=chrome.runtime.getURL(`/assets/js/${pages[_]}.js`)):false)
    document.documentElement.appendChild(a).remove()
    const b=document.createElement('link'); b.rel='stylesheet'
    Object.getOwnPropertyNames(pages).some(_=>RegExp(_).test(location.href)?!!(b.href=chrome.runtime.getURL(`/assets/css/${pages[_]}.css`)):false)
    document.head.append(b);
}
catch(err) {}

})()