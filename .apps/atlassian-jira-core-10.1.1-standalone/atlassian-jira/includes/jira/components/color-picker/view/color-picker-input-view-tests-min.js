AJS.test.require(["jira.webresources:color-picker"],(function(){"use strict";var e=require("jira/backbone-1.3.3"),o=require("jquery"),t="black",i="#qunit-fixture";module("Color picker input view component",{setup:function(){this.sandbox=sinon.sandbox.create();this.stubColorPicker();this.model=new e.Model({color:t,colorDefined:!0});var o=require("jira/components/color-picker/view/color-picker-input-view").extend({el:i});this.colorPickerView=new o({model:this.model});this.onColorSelectedStub=this.sandbox.stub();this.colorPickerView.on("color:selected",this.onColorSelectedStub);this.colorPickerView.render()},stubColorPicker:function(){var e=this;this.sandbox.stub(o.fn,"ColorPicker",(function(o){e.colorPickerOnSubmit=o.onSubmit;e.colorPickerOnChange=o.onChange}));this.sandbox.stub(o.fn,"ColorPickerSetColor");this.sandbox.stub(o.fn,"ColorPickerShow");this.sandbox.stub(o.fn,"ColorPickerHide")},teardown:function(){this.sandbox.restore()},getInput:function(){return o("".concat(i," input"))},getPreview:function(){return o("".concat(i," .color-preview"))},triggerKeyUp:function(e){this.getInput().val(e);this.getInput().trigger("keyup")}});test("When model triggers color change, input field changes value",(function(){var e="yellow";equal(this.getInput().val(),t);equal(this.getPreview().get(0).style.backgroundColor,t);this.model.set("color",e);equal(this.getInput().val(),e);equal(this.getPreview().get(0).style.backgroundColor,e);ok(this.getInput().ColorPickerSetColor.calledOnce);ok(this.getInput().ColorPickerSetColor.calledWith(e))}));test("When model triggers color defined change, color preview may disappear",(function(){this.model.set("colorDefined",!0);ok(this.getPreview().is(":visible"));this.model.set("colorDefined",!1);notOk(this.getPreview().is(":visible"))}));test("When someone type into field, event is triggered",(function(){ok(this.onColorSelectedStub.notCalled);var e="new value";this.triggerKeyUp(e);ok(this.onColorSelectedStub.calledOnce);ok(this.onColorSelectedStub.calledWith(e));var o="new value version 2";this.triggerKeyUp(o);ok(this.onColorSelectedStub.calledTwice);ok(this.onColorSelectedStub.calledWith(o))}));test("When someone change value in color picker, event is triggered",(function(){ok(this.onColorSelectedStub.notCalled);var e="new val";this.colorPickerOnChange("color",e);ok(this.onColorSelectedStub.calledOnce);ok(this.onColorSelectedStub.calledWith("#".concat(e)));ok(this.getInput().ColorPickerHide.notCalled)}));test("When someone submit value in color picker, event is triggered and picker is hidden",(function(){ok(this.onColorSelectedStub.notCalled);ok(this.getInput().ColorPickerHide.notCalled);var e="new val 2";this.colorPickerOnSubmit("color",e);ok(this.onColorSelectedStub.calledOnce);ok(this.onColorSelectedStub.calledWith("#".concat(e)));ok(this.getInput().ColorPickerHide.calledOnce)}))}));