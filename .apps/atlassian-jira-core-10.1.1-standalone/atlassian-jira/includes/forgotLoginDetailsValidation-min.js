require(["jira/util/init-on-dcl","jira/util/formatter"],(function(e,r){"use strict";e((function(){var e=document.querySelector("#forgot-login");e.addEventListener("submit",(function(t){var i=e.querySelector(".field-group:not(.hidden)");if(!i)return;var n=i.querySelector("input");if(!n)return;t.preventDefault();var o=i.querySelector(".error");if(""===n.value){if(!o){var u=n.getAttribute("name"),a='<div class="error">'.concat(function(e){switch(e){case"username":return r.I18n.getText("forgotlogindetails.error.username.required");case"email":return r.I18n.getText("forgotlogindetails.error.email.required");default:return r.I18n.getText("forgotlogindetails.error.default")}}(u),"</div>");i.insertAdjacentHTML("beforeend",a)}}else{o&&i.removeChild(o);e.submit()}}))}))}));