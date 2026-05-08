const saveOptions = async () => {
    const options = {
        disableOnWishlistPage: document.getElementById('disable-on-wishlist-page').checked,
        disableOnHover: document.getElementById('disable-on-hover').checked,
        token: document.getElementById('token').value,
        hideDifficulty: document.getElementById('hide-difficulty').checked,
        hidePlaythroughs: document.getElementById('hide-playthroughs').checked,
        hideHours: document.getElementById('hide-hours').checked,
        hideMissables: document.getElementById('hide-missables').checked,
        hideOnline: document.getElementById('hide-online').checked,
        hidePostLaunchAchvs: document.getElementById('hide-post-launch-achvs').checked,
        hidePaidDlcRequired: document.getElementById('hide-paid-dlc-required').checked,
        hideDifficultySpecific: document.getElementById('hide-difficulty-specific').checked,
        hideUnobtainables: document.getElementById('hide-unobtainables').checked,
        hideCondObtainables: document.getElementById('hide-cond-obtainables').checked,
        hideBroken: document.getElementById('hide-broken').checked,
        hideNaValues: document.getElementById('hide-na-values').checked
    };

    await chrome.storage.sync.set(options);
};

const restoreOptions = async () => {
    const options = await chrome.storage.sync.get();
    document.getElementById('disable-on-wishlist-page').checked = !!options.disableOnWishlistPage;
    document.getElementById('disable-on-hover').checked = !!options.disableOnHover;
    document.getElementById('token').value = options.token || '';
    document.getElementById('hide-difficulty').checked = !!options.hideDifficulty;
    document.getElementById('hide-playthroughs').checked = !!options.hidePlaythroughs;
    document.getElementById('hide-hours').checked = !!options.hideHours;
    document.getElementById('hide-missables').checked = !!options.hideMissables;
    document.getElementById('hide-online').checked = !!options.hideOnline;
    document.getElementById('hide-post-launch-achvs').checked = !!options.hidePostLaunchAchvs;
    document.getElementById('hide-paid-dlc-required').checked = !!options.hidePaidDlcRequired;
    document.getElementById('hide-difficulty-specific').checked = !!options.hideDifficultySpecific;
    document.getElementById('hide-unobtainables').checked = !!options.hideUnobtainables;
    document.getElementById('hide-cond-obtainables').checked = !!options.hideCondObtainables;
    document.getElementById('hide-broken').checked = !!options.hideBroken;
    document.getElementById('hide-na-values').checked = !!options.hideNaValues;

    document.getElementById('disable-on-wishlist-page').addEventListener('input', saveOptions);
    document.getElementById('disable-on-hover').addEventListener('input', saveOptions);
    document.getElementById('token').addEventListener('input', saveOptions);
    document.getElementById('hide-difficulty').addEventListener('input', saveOptions);
    document.getElementById('hide-playthroughs').addEventListener('input', saveOptions);
    document.getElementById('hide-hours').addEventListener('input', saveOptions);
    document.getElementById('hide-missables').addEventListener('input', saveOptions);
    document.getElementById('hide-online').addEventListener('input', saveOptions);
    document.getElementById('hide-post-launch-achvs').addEventListener('input', saveOptions);
    document.getElementById('hide-paid-dlc-required').addEventListener('input', saveOptions);
    document.getElementById('hide-difficulty-specific').addEventListener('input', saveOptions);
    document.getElementById('hide-unobtainables').addEventListener('input', saveOptions);
    document.getElementById('hide-cond-obtainables').addEventListener('input', saveOptions);
    document.getElementById('hide-broken').addEventListener('input', saveOptions);
    document.getElementById('hide-na-values').addEventListener('input', saveOptions);
};

document.addEventListener('DOMContentLoaded', restoreOptions);