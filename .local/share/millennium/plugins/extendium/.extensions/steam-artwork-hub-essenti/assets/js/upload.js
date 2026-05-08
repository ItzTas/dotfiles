const DFM_DRAGENTER=(e)=>{
    e.preventDefault();
    $J('#DFM_LABEL').addClass('HOVERED');
}

const DFM_DRAGOVER=(e)=>{
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    $J('#DFM_LABEL').addClass('HOVERED');
}

const DFM_DRAGLEAVE=(e)=>{
    e.preventDefault();
    $J('#DFM_LABEL').removeClass('HOVERED');
}

const DFM_DROP=(e)=>{
    e.preventDefault();
    $J('#DFM_LABEL').removeClass('HOVERED');
    DFM_PUT(e.dataTransfer.files);
}

const DFM_UPLOAD=()=>{
    $J('.DFM_FORM:not(.unready, .unhexed, .lock)').addClass('lock').submit();
}

const DFM_LONG=(i,e)=>{
    if (e.checked)
    {
        return  $J(`#f_${i} .lon_w`).attr({'name':'image_width'}),
                $J(`#f_${i} .lon_h`).attr({'name':'image_height'}),
                $J(`#f_${i} .img_w, #f_${i} .img_h`).attr({'name':''});
    }
    else
    {
        return  $J(`#f_${i} .img_w`).attr({'name':'image_width'}),
                $J(`#f_${i} .img_h`).attr({'name':'image_height'}),
                $J(`#f_${i} .lon_w, #f_${i} .lon_h`).attr({'name':''});
    }
}

const DFM_PUT=(input_files)=>{

    for(const el of input_files)
    {
        if(el.size > 5242880 || !['image/jpeg', 'image/png', 'image/gif'].includes(el.type)) continue;

        let name = el.name.split('.');
        name.pop();
        name=name.join('.');

        const container = $J(`
        <form id="f_${g_ID}" class="DFM_FORM unready" onsubmit="$J('#f_${g_ID} .DFM_LOADING_OUTER').show()" name="SubmitItemForm" enctype="multipart/form-data" method="POST" action="${DFM_FORMURL}" target="i_${g_ID}">
            <div class="DFM_LOADING_OUTER"><div class="DFM_LOADING_INNER"><div class="DFM_LOADING_SPEEN"></div></div></div>
            <input type="hidden" name="redirect_uri" value="https://steamcommunity.com/sharedfiles/filedetails/">
            <input type="hidden" class="ftype" value="${el.type}">
            <input type="hidden" name="wg" value="${DFM_WG}">
            <input type="hidden" name="wg_hmac" value="${DFM_WG_HMAC}">
            <input type="hidden" name="token" value="${DFM_TOKEN}">
            <input type="hidden" name="sessionid" value="${DFM_SESSION}">
            <input type="hidden" name="cloudfilenameprefix" value="${Date.now()}_">
            <input type="hidden" name="publishedfileid" value="0">
            <input type="hidden" name="id" value="0">
            <input type="hidden" name="appid" value="766">
            <input type="hidden" id="cons_${g_ID}" name="consumer_app_id" value="767">
            <input type="file" name="file" class="file" hidden="true">
            <input type="hidden" name="image_width" class="img_w" value="0">
            <input type="hidden" name="image_height" class="img_h" value="0">
            <input type="hidden" name="" class="lon_w" value="-1">
            <input type="hidden" name="" class="lon_h" value="1">
            <input type="checkbox" name="agree_terms" hidden="true" checked="true">
            <a class="DFM_REMOVE" onclick="$J('#f_${g_ID}').remove()">Remove</a>
            <img class="DFM_IMG" hidden="true" onload="$J('#f_${g_ID} .img_w').val(this.width),$J('#f_${g_ID} .img_h').val(this.height),$J('#f_${g_ID}').removeClass('unready')" onerror="$J('#f_${g_ID}').addClass('lock error').removeClass('unready')"></img>
            <img class="DFM_IMG" hidden="false" draggable="false"></img>
            <div class="DFM_STATS">
            <div class="fname"></div>
            <div class="fsize"></div>
            </div>
            <input type="text" class="titleField" name="title" maxlength="128" value="${name}" placeholder="${DFM_TITLE}">
            <a class="DFM_BTN small" onclick="$J('#f_${g_ID} .titleField').val(' \\n'+Array.from(Array(126),_=>'\\t').join(''))"><span>Hide Title</span></a>
            <span class="tooltip" data-tooltip-html="
            Fills the <b>Title</b> field with a sequence of special characters that make your artwork title disappear from your showcase.
            <br/><br/><img src='https://i.ibb.co/g9xLqJt/tooltip-1.png'></img>
            ">(?)</span>
            <div class="workshopDescContainer">
                <textarea class="descField" name="description" maxlength="8000" placeholder="${DFM_DESCRIPTION}"></textarea>
                <div class="workshopFormattingHelpContainer">
                    <a class="whiteLink" onclick="CCommentThread.FormattingHelpPopup('GreenlightItem')">${DFM_FORMATTING}</a>
                </div>
            </div>
            <br/><br/>
            <input type="checkbox" id="l_${g_ID}" class="inputTagsFilter longart" onchange="DFM_LONG(${g_ID},this)">
            <label for="l_${g_ID}">Enable Long Artworks and Long Screenshots</label>
            <span class="tooltip" data-tooltip-html="
            Enable this option if you are uploading a <b>long artwork</b> or a <b>long screenshot</b>.
            <br/><br/><img src='https://i.ibb.co/tMqpgw7/animated.png'></img>
            ">(?)</span>
            ${(el.size==5242880&&el.type=='image/png')?'':`
            <br/>
            <input type="checkbox" id="p_${g_ID}" class="inputTagsFilter prehex" onchange="DFM_HEX(${g_ID},this)">
            <label for="p_${g_ID}">Enable Transparency, Long Workshops and Long Guides</label>
            <span class="tooltip" data-tooltip-html="
            Enable this option if you are uploading a <b>transparent</b> artwork, screenshot, workshop or guide. Also enable this option if you are uploading a <b>long workshop</b> or a <b>long guide</b>.
            <br/><br/><img src='https://i.ibb.co/8z535tm/tooltip-3.png'></img>
            ">(?)</span>
            `}
            <br/>
            <div class="DFM_SECTION">
                <div class="title">What are you uploading?</div>
                <div class="visibilityOption"><input type="radio" id="ft0_${g_ID}" name="file_type" value="3" checked><label for="ft0_${g_ID}">Artwork</label></div>
                <div class="visibilityOption"><input type="radio" id="ft1_${g_ID}" name="file_type" value="5"><label for="ft1_${g_ID}">Screenshot</label></div>
                <div class="visibilityOption"><input type="radio" id="ft2_${g_ID}" name="file_type" value="0"><label for="ft2_${g_ID}">Workshop</label></div>
                <div class="visibilityOption"><input type="radio" id="ft3_${g_ID}" name="file_type" value="9"><label for="ft3_${g_ID}">Guide</label></div>
            </div>
            <div class="DFM_SECTION">
                <div class="title">${DFM_SETVISIBILITY}</div>
                <div class="visibilityOption"><input type="radio" id="v0_${g_ID}" name="visibility" value="0" checked><label for="v0_${g_ID}">${DFM_VISIBILITY[0]}</label></div>
                <div class="visibilityOption"><input type="radio" id="v1_${g_ID}" name="visibility" value="1"><label for="v1_${g_ID}">${DFM_VISIBILITY[1]}</label></div>
                <div class="visibilityOption"><input type="radio" id="v2_${g_ID}" name="visibility" value="2"><label for="v2_${g_ID}">${DFM_VISIBILITY[2]}</label></div>
                <div class="visibilityOption"><input type="radio" id="v3_${g_ID}" name="visibility" value="3"><label for="v3_${g_ID}">${DFM_VISIBILITY[3]}</label></div>
            </div>
            <div class="DFM_RESULT"></div>
            <iframe id="i_${g_ID}" name="i_${g_ID}" hidden="true" onload="DFM_IFRAME(this)" width="900" height="600" src="data:text/html;base64,PGgzPjwvaDM+"></iframe>
        </form>
        `);
        container.appendTo(`#DFM_LIST`);
        let gid = g_ID;
        for (let i = 0; i < 3; i++)
        {
            $J(`#ft${i}_${gid}`).on('change', (event)=>{
                $J(`#cons_${gid}`)[0].value = (event.target.value == '0') ? '480' : '767';
            });
        }
        
        let fr = new FileReader();
        fr.onload=()=>container.find('.DFM_IMG').attr({'src':fr.result});
        fr.readAsDataURL(el);

        let dt = new DataTransfer(); dt.items.add(el);
        $J(`#f_${g_ID} .file`)[0].files = dt.files;
        $J(`#f_${g_ID} .fname`).text(el.name);
        $J(`#f_${g_ID} .fsize`).text((el.size/1024/1024).toFixed(4)+' MiB');
        g_ID++;
    }
    $J('#DFM_MAINFORM')[0].reset();
}

const DFM_HEX=(i, e)=>{
    $J(`#f_${i}`).addClass('unhexed');

    const fr = new FileReader();
    fr.onload=()=>{

        let arr = [...new Uint8Array(fr.result)];

        const nam = $J(`#f_${i} .file`)[0].files[0].name;
        const typ = $J(`#f_${i} .ftype`).val();
        switch(typ)
        {
            case 'image/jpeg':
            {
                if (e.checked)
                {
                    if (arr[arr.length - 1] == 0xd9) arr[arr.length - 1] = 0xda;
                    break;
                }
                else
                {
                    if (arr[arr.length - 1] == 0xda) arr[arr.length - 1] = 0xd9;
                    break;
                }
            }

            case 'image/gif':
            {
                if (e.checked)
                {
                    if (arr[arr.length - 1] == 0x3b) arr[arr.length - 1] = 0x21;
                    break;
                }
                else
                {
                    if (arr[arr.length - 1] == 0x21) arr[arr.length - 1] = 0x3b;
                    break;
                }
            }

            case 'image/png':
            {
                if (e.checked)
                {
                    if (
                        arr[arr.length -12] == 0x00 &&
                        arr[arr.length -11] == 0x00 &&
                        arr[arr.length -10] == 0x00 &&
                        arr[arr.length - 9] == 0x00 &&
                        arr[arr.length - 8] == 0x49 &&
                        arr[arr.length - 7] == 0x45 &&
                        arr[arr.length - 6] == 0x4E &&
                        arr[arr.length - 5] == 0x44 &&
                        arr[arr.length - 4] == 0xAE &&
                        arr[arr.length - 3] == 0x42 &&
                        arr[arr.length - 2] == 0x60 &&
                        arr[arr.length - 1] == 0x82
                    )
                    arr = arr.slice(0,  -9).concat([0x01,0x49,0x45,0x4E,0x44,0x00,0xD1,0x1A,0x4F,0xE1]);
                    break;
                }
                else
                {
                    if (
                        arr[arr.length -13] == 0x00 &&
                        arr[arr.length -12] == 0x00 &&
                        arr[arr.length -11] == 0x00 &&
                        arr[arr.length -10] == 0x01 &&
                        arr[arr.length - 9] == 0x49 &&
                        arr[arr.length - 8] == 0x45 &&
                        arr[arr.length - 7] == 0x4E &&
                        arr[arr.length - 6] == 0x44 &&
                        arr[arr.length - 5] == 0x00 &&
                        arr[arr.length - 4] == 0xD1 &&
                        arr[arr.length - 3] == 0x1A &&
                        arr[arr.length - 2] == 0x4F &&
                        arr[arr.length - 1] == 0xE1
                    )
                    arr = arr.slice(0, -10).concat([0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82]);
                    break;
                }
            }
        }

        const dt = new DataTransfer();
        dt.items.add(new File([Uint8Array.from(arr)], nam)); 
        $J(`#f_${i} .file`)[0].files = dt.files;
        $J(`#f_${i}`).removeClass('unhexed');
    }
    fr.readAsArrayBuffer($J(`#f_${i} .file`)[0].files[0]);
}

const DFM_IFRAME=(t)=>{
    try
    {
        const err = $J(t.contentDocument.querySelector('h3')).text();
        if (!err.length && typeof t.contentWindow.publishedfileid === 'undefined') return;
        $J(t).parent().find('.DFM_LOADING_OUTER').hide();
        if (err) return $J(t).parent().addClass('error').find('.DFM_RESULT').show().text(err);
        else return $J(t).parent().addClass('done').find('.DFM_RESULT').show().html(`<a target="_blank" href="https://steamcommunity.com/sharedfiles/filedetails/?id=${t.contentWindow.publishedfileid}">File uploaded successfully (click to open).</a>`);
    }
    catch(e) {}
}

var g_ID = 0;

const DFM_FORMURL = $J('#SubmitItemForm')[0].action;
const DFM_SESSION = $J('[name=sessionid]').val();
const DFM_WG = $J('[name=wg]').val();
const DFM_WG_HMAC = $J('[name=wg_hmac]').val();
const DFM_TOKEN = $J('[name=token]').val();
const DFM_TITLE = $J('.title')[0].innerText;
const DFM_FORMATS = $J('.description')[0].innerText;
const DFM_DESCRIPTION = $J('.title')[2].innerText;
const DFM_FORMATTING = $J('.whiteLink')[0].innerText;
const DFM_CONTINUE = $J('.btn_blue_white_innerfade.btn_medium').text();
const DFM_AUTHOR = $J('p')[2].innerHTML.trim();
const DFM_SETVISIBILITY = $J('.title')[3].innerText;
const DFM_VISIBILITY = [
    $J('[for=Visibility0]').text(),
    $J('[for=Visibility1]').text(),
    $J('[for=Visibility2]').text(),
    $J('[for=Visibility3]').text()
];

$J('form').parent()[0].id='DFM_LIST',$J('.pageDesc').text(''),$J('form,.apphub_HomeHeaderContent').remove();
$J(`<form id="DFM_MAINFORM"><label id="DFM_LABEL" for="DFM_FILELIST" ondragenter="DFM_DRAGENTER(event)" ondragleave="DFM_DRAGLEAVE(event)" ondragover="DFM_DRAGOVER(event)" ondrop="DFM_DROP(event)"><span>CLICK OR DRAG & DROP TO UPLOAD<br/><font size="2">${DFM_FORMATS}</font></span></label><input type="file" id="DFM_FILELIST" hidden multiple/></form>`).appendTo('#DFM_LIST');
$J(`<div class="detailBox"><a onclick="DFM_UPLOAD()" class="DFM_BTN"><span>Upload</span></a></div>`).insertAfter('#DFM_LIST');
$J('#DFM_FILELIST').on('change',()=>DFM_PUT($J('#DFM_FILELIST')[0].files));