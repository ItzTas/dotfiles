define("jira/ajs/select/select-model",["jira/ajs/control","jira/ajs/list/group-descriptor","jira/ajs/list/item-descriptor","jira/util/objects","jquery"],(function(e,t,i,n,s){"use strict";return e.extend({init:function(e){var t=this,i={};e&&(e instanceof s?i.element=e:e instanceof Element||"string"==typeof e?i.element=s(e):i=e);this._setOptions(i);this.$element=this.options.element.hide();this.type=this.$element.attr("multiple")?"multiple":"single";this.id=this.$element.attr("id")||this.$element.attr("name");"single"===this.type&&this.$element.attr("multiple","multiple");this.$element.bind("reset",(function(){t._parseDescriptors()}));this._parseDescriptors()},hasOptionByValue:function(e){return this.$element.find('option[value="'+e+'"]').length>0},getSelectedTexts:function(){for(var e=[],t=this.getDisplayableSelectedDescriptors(),i=0;i<t.length;i++)e.push(t[i].label());return e},putOption:function(e,t,i){var n;if(this.hasOptionByValue(e)){var r=this.getDescriptor(e);t||(t=r.label());n=r.model()}else{n=s("<option/>");this.$element.append(n)}i&&n.addClass("hidden");t&&n.text(t);n.attr("value",e);this._parseOption(n)},changeSelectionByValue:function(e){var t=this.getDescriptor(e);if(t){this.setSelected(t)||this.$element.trigger("change",t);return!0}return!1},_getFreeInputEl:function(){return this.$element.find(".free-input")},removeFreeInputVal:function(){this._getFreeInputEl().remove()},updateFreeInput:function(e){var t=this._getFreeInputEl();if(e=s.trim(e)){t.length||(t=s("<option class='free-input' />").appendTo(this.$element));t.attr({value:e,selected:"selected"})}else t.remove()},_getDefaultOptions:function(){return{}},getSelectedValues:function(){for(var e=[],t=this.getDisplayableSelectedDescriptors(),i=0;i<t.length;i++)e.push(t[i].value());return e},setSelected:function(e){var t=this,i=!1,n=!1,r=this.$element.find("option").not(this._getExclusions()).filter((function(){return this.value===e.value()}));if("single"===this.type){if(this.getValue()===e.value())return n;r=r.first();this.$element.find("option:selected").not(this._getExclusions()).each((function(e,i){var n=s(this).data("descriptor");r[0]!==i&&t.setUnSelected(n)}))}r.each((function(){var t=s(this);i=!0;n=!t.is(":selected");t.attr("selected","selected").data("descriptor").selected(!0);e.properties&&(e.properties.selected=!0)}));if(!i){e.selected(!0);e.removeOnUnSelect(!0);var l=this._render("option",e);l.attr("selected","selected");this.$element.append(l);n=!0}e.highlighted(!1);n&&this.$element.trigger("change",e);return n},setAllSelected:function(){var e=this;s(this.getDisplayableUnSelectedDescriptors()).each((function(){e.setSelected(this)}))},setAllUnSelected:function(){var e=this;s(this.getDisplayableSelectedDescriptors()).each((function(){e.setUnSelected(this)}))},setUnSelected:function(e){var t=this,i=e.value();this.$element.find("option:selected").not(this._getExclusions()).filter((function(){return s(this).attr("value")===i})).each((function(){var i=s(this);i.data("descriptor").selected(!1);e.properties&&(e.properties.selected=!1);t.options.removeOnUnSelect||i.data("descriptor").removeOnUnSelect()?i.remove():i.removeAttr("selected")}))},remove:function(e){e&&e.model()&&e.model().remove()},getDescriptor:function(e){var t;e=s.trim(e.toLowerCase());s.each(this.getAllDescriptors(!1),(function(i,n){if(e===s.trim(n.label().toLowerCase())||e===s.trim(n.value().toLowerCase())){t=n;return!1}}));return t},_parseOption:function(e){var t,n,r,l;e=s(e);if(this.options.removeNullOptions&&this._hasNullValue(e)){e.remove();return null}n=e.attr("data-icon");r=e.attr("data-icon-type");l=e.attr("data-fallback-icon");t=new i({styleClass:e.prop("className"),value:e.val(),invalid:e.hasClass("invalid_sel"),fieldText:e.attr("data-field-text"),title:e.attr("title"),labelSuffix:e.attr("data-label-suffix"),meta:e.data("meta"),label:e.attr("data-field-label")||s.trim(e.text()),icon:n||e.css("backgroundImage").replace(/url\(['"]?(.*?)['"]?\)/,"$1"),iconType:r||void 0,fallbackIcon:l||"none",selected:e.prop("selected"),removeOnUnSelect:!!e.data("remove-on-unselect"),model:e});e.data("descriptor",t);return t},_hasNullValue:function(e){return e.val()<0},_parseDescriptors:function(){var e=this,i=this.$element.children();function n(t){var i=s("option",t),n=[];s.each(i,(function(){n.push(e._parseOption(this))}));return n}i.each((function(s){var r=i.eq(s);if(r.is("optgroup"))!function(e){var i={label:e.attr("label"),placement:e.attr("data-placement"),footerText:e.attr("data-footer-text"),styleClass:e.prop("className"),model:e,items:n(e)},s=e.data("weight");s&&(i.weight=+s);e.data("descriptor",new t(i))}(r);else if(r.is("option"))if(r.attr("data-placeholder")){e.placeholder=r.text();r.remove()}else e._parseOption(r)}))},getPlaceholder:function(){return this.placeholder},_getExclusions:function(){return".free-input"},getValue:function(){return"single"===this.type?this.$element.val()&&this.$element.val()[0]:this.$element.val()},getDisplayableSelectedDescriptors:function(){var e=[];this.$element.find("option:selected").not(this._getExclusions()).each((function(){e.push(s.data(this,"descriptor"))}));return e},getDisplayableUnSelectedDescriptors:function(){var e=[];this.$element.find("option").not(":selected").not(this._getExclusions()).each((function(){e.push(s.data(this,"descriptor"))}));return e},getAllDescriptors:function(e){var i,r=[];this.$element.children().each((function(){var l,a=s(this);if(a.is("option"))a.data("descriptor")&&r.push(a.data("descriptor"));else if(a.is("optgroup")){if(!1!==e){var o=a.data("descriptor");if(o){(i=n.copyObject(o.allProperties(),!1)).items=[];l=new t(i);r.push(l)}}a.children("option").each((function(){var t=s(this).data("descriptor");t&&(!1!==e?l.addItem(t):r.push(t))}))}}));return r},clearUnSelected:function(){this.$element.find("option:not(:selected)").not(this._getExclusions()).remove()},getUnSelectedDescriptors:function(){var e=this,i=[],r={},l={};function a(e){var t=e.value().toLowerCase();if(!(r[t]||l[t]&&!1===e.allowDuplicate())){l[t]=!0;return!0}return!1}var o=this.getDisplayableSelectedDescriptors();s.each(o,(function(e,t){r[t.value().toLowerCase()]=!0}));this.$element.children().each((function(){var r,l,o=s(this);if(o.is("option")&&!this.selected)a(r=s.data(this,"descriptor"))&&i.push(r);else if(o.is("optgroup")){(l=n.copyObject(o.data("descriptor").allProperties(),!1)).items=[];r=new t(l);i.push(r);o.find("option").not(e._getExclusions()).each((function(e){if(!e.selected){var t=s.data(this,"descriptor");a(t)&&r.addItem(t)}}))}}));return i},_renders:{option:function(e){var t=e.label(),i=e.fieldText()||t,n=new Option(i,e.value()),r=s(n),l=e.icon();n.title=e.title();i!=t&&r.data("field-label",t);e.selected()&&r.attr("selected","selected");s.data(n,"descriptor",e);e.model(r);l&&r.css("backgroundImage","url("+l+")");return r},optgroup:function(e){var t=s("<optgroup />").addClass(e.styleClass()).attr("label",e.label());e.model(t);t.data("descriptor",e);e.id()&&t.attr("id",e.id());return t}}})}));AJS.namespace("AJS.SelectModel",null,require("jira/ajs/select/select-model"));