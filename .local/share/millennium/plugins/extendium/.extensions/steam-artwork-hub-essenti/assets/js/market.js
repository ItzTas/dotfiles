try
{
    const elm = $J('.btn_small.btn_grey_white_innerfade');
    if (/\/items\/.*/g.test(elm[0].href))
    {
        $J(`
        <a class="btn_small btn_grey_white_innerfade" href="https://steamartworkhub.com/bgcropper#${elm[0].href};0">
        <span>Crop This Background</span>
        </a>`).insertAfter(elm[0]);
    }
}
catch(err) {}