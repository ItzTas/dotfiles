const g_URLParams = new URLSearchParams(window.location.search);
var DFM_TempTheme = localStorage.DFM_CustomTheme;

try
{
    const DFM_FILL=()=>
    $J('.btn_small.btn_grey_white_innerfade[href^="https://steamcdn-a.akamaihd.net/steamcommunity/public/images/items/"]').each((i,e)=>{
        if ($J(e).hasClass('B')) return;
        $J(e).addClass('B'),$J(`<a class="btn_small btn_grey_white_innerfade" href="https://steamartworkhub.com/bgcropper#${e.href};0"><span>Crop This Background</span></a>`).insertAfter(e);
    });

    const DFM_OBSERVER = new MutationObserver(mutation_list=>DFM_FILL());
    DFM_FILL(),DFM_OBSERVER.observe($J('.inventory_page_right')[0], { subtree: true, childList: true });
}
catch(err) {}

try
{
    const DFM_CLASSLIST = [...$J('body')[0].classList];
    if(
        (typeof localStorage.DFM_CustomTheme !== 'undefined') &&
        g_rgProfileData.steamid == g_steamID    &&(
        DFM_CLASSLIST.includes('DefaultTheme')  ||
        DFM_CLASSLIST.includes('CosmicTheme')   ||
        DFM_CLASSLIST.includes('SummerTheme')   ||
        DFM_CLASSLIST.includes('MidnightTheme') ||
        DFM_CLASSLIST.includes('DarkModeTheme') ||
        DFM_CLASSLIST.includes('SteelTheme'))   ){

        $J('body').addClass(`DFM_CustomTheme ${localStorage.DFM_CustomTheme}`);
    }
}
catch(err) {}

function DFM_PrepareForApplying()
{
    const len = $J('[class^=profiletheme_ProfileTheme_]').length;
    if (len === 6) DFM_AddNewThemes();
}

function DFM_AddNewThemes()
{
    DFM_TempTheme = localStorage.DFM_CustomTheme;
    
    const DFM_ApplyTheme = (e, overwrite)=>
    {
        if (overwrite) DFM_TempTheme = e.currentTarget.dataset.theme;
        else DFM_TempTheme = undefined;

        $J('.submissive').removeClass('DFM_Active');
        $J(e.currentTarget).addClass('DFM_Active');
    };
    
    const source_ = $J('[class^=profileeditshell_PageContent_] [class^=profileedit_ItemPickerList_] [class^=profiletheme_ProfileTheme_]').first();
    
    if (source_.length)
    {
        $J('.DialogButton._DialogLayout.Primary').bind('click', ()=>{
            if (typeof DFM_TempTheme === 'undefined') delete localStorage.DFM_CustomTheme;
            else localStorage.DFM_CustomTheme = DFM_TempTheme;
        });

        const hasL = [...source_[0].classList].find(e=>e.startsWith('profiletheme_Active_'));
        
        const DFM_AddTheme = (themename, themeclass, overwrite)=>{
            const clon = source_.clone(false, true);
            if (typeof hasL !== 'undefined') clon.removeClass(hasL);
            clon.appendTo($J('[class^=profileedit_ItemPickerList_]'))
            .addClass(`submissive ${themeclass}`).attr({'data-theme':themeclass})
            .on('click', (e)=>{if ($J(e.currentTarget).hasClass('DFM_Active')) return; DFM_ApplyTheme(e, overwrite)}).find('div:last').text(themename);
            if (!overwrite) clon.addClass('DFM_Active');
        };
    
        $J('[class^=profileedit_ItemPickerList_]').append('<div/><div class="DFM_Separator"/><div/>');
        
        //Custom Themes
        DFM_AddTheme('None', '', false);
        if(g_URLParams.get('debug') == true)
        DFM_AddTheme('Debug', 'DFM_CustomTheme DFM_DebugTheme', true);
        DFM_AddTheme('Transparent', 'DFM_CustomTheme DFM_TransparentTheme', true);
        DFM_AddTheme('Artwork Hub', 'DFM_CustomTheme DFM_ArtworkHubTheme', true);
        DFM_AddTheme('Steam Fever', 'DFM_CustomTheme DFM_SteamFeverTheme', true);

        $J(`[data-theme="${DFM_TempTheme}"]`).click();
    }
}

const DFM_LISTOBSERVER = new MutationObserver(DFM_PrepareForApplying);
DFM_LISTOBSERVER.observe($J('.responsive_page_template_content')[0], { subtree: true, childList: true });
DFM_PrepareForApplying();

$J('.imgWallItem').each((i,e)=>{
    if ($J('.image_grid_dates').length) $J(e).css({'background-image':$J(e).css('background-image').replace(/\?/g, '#')}).parent().css({'height':'191.6px'});
});