define("jira/ajs/select/multi-select/lozenge",["jira/util/formatter","jira/util/assistive","jira/util/strings","jira/ajs/control","jquery"],(function(e,t,n,s,i){"use strict";var o,l=0;return s.extend({init:function(e){this.id=l;l+=1;this._setOptions(e);this.$lozenge=this._render("lozenge");this.$removeButton=this._render("removeButton");this.$removeButton.tooltip("disable");this._assignEvents("instance",this);this._assignEvents("lozenge",this.$lozenge);this._assignEvents("removeButton",this.$removeButton);this.$removeButton.appendTo(this.$lozenge);this.$lozenge.appendTo(this.options.container)},_getDefaultOptions:function(){return{label:null,title:null,container:null,focusClass:"focused"}},_renders:{lozenge:function(){var s=n.escapeHtml(this.options.label);o||(o=t.createOrUpdateLabel(e.I18n.getText("common.concepts.remove.option.label")));return i('<li class="item-row" role="option"><button type="button" tabindex="-1" class="value-item"><span><span class="value-text">'+s+"</span></span></button></li>").attr({"aria-describedby":o,id:"item-row-"+this.id})},removeButton:function(){return i('<span class="aui-icon aui-icon-small aui-iconfont-cross item-delete"></span>')}},_events:{instance:{focus:function(){this.$lozenge.addClass(this.options.focusClass)},blur:function(){this.$lozenge.removeClass(this.options.focusClass)},remove:function(){this.$lozenge.remove()}},lozenge:{click:function(){this.trigger("focus")}},removeButton:{click:function(){this.trigger("remove")}}}})}));AJS.namespace("AJS.MultiSelect.Lozenge",null,require("jira/ajs/select/multi-select/lozenge"));