AJS.test.require(["jira.webresources:jqlautocomplete"],(function(){"use strict";var e=require("jquery"),t=require("jira/ajs/list/item-descriptor"),o=require("jira/ajs/list/group-descriptor"),l=require("jira/ajs/select/select-model");function n(o,l){return e("<option />").attr("value",o).prop("selected",l).data("descriptor",new t({value:o,label:"Does not matter",selected:l}))}function i(t,l){var n=new o({label:t}),i=e("<optgroup />").attr("label",t).data("descriptor",new o({label:t}));e.each(l,(function(){this.appendTo(i);n.addItem(this.data("descriptor"))}));return i}test("ItemDescriptor",(function(){var o=e("<option />"),l=new t({value:"test",title:"I am a test title",selected:!0,label:"I am a test label",styleClass:"test-class",icon:"url()",model:o});equal(l.value(),"test");equal(l.title(),"I am a test title");equal(l.label(),"I am a test label");equal(l.icon(),"url()");equal(l.selected(),!0);equal(l.styleClass(),"test-class");var n=new XMLSerializer;equal(n.serializeToString(l.model()[0]),n.serializeToString(o[0]),"Expected model() to be jQuery wrapped option element")}));test("GroupDescriptor",(function(){var t=e("<optgroup />"),l=new o({label:"I am a test label",weight:10,styleClass:"test-class",showLabel:!0,replace:!0,description:"I am a test description",model:t});equal(l.description(),"I am a test description");equal(l.label(),"I am a test label");equal(l.weight(),10);equal(l.showLabel(),!0);equal(l.styleClass(),"test-class");var n=new XMLSerializer;equal(n.serializeToString(l.model()[0]),n.serializeToString(t[0]),"Expected model() to be jQuery wrapped option element")}));test("Setting Selected",(function(){function o(o,l,n){var i,s;n&&(i=e("<option />").attr({value:o,label:l}));s=new t({value:o,label:l,model:i});n&&i.data("descriptor",s);return s}var n=new(l.extend({init:function(){this.options={};this.$element=e("<select multiple='multiple' />")}})),i=o("kelly-slator","Kelly Slator",!0);n.$element.append(i.model());n.setSelected(i);ok(i.model().prop("selected"),"Expected option [Kelly Slator] to be selected");ok(i.selected(),"Expected descriptor [kellySlaterDescriptor] to be selected");var s=o("kelly-slator","k-dog",!0);n.$element.append(s.model());n.setSelected(i);ok(s.model().prop("selected")&&i.model().prop("selected"),"Expected option [Kelly Slator] and [k-dog] to be selected");ok(s.selected()&&i.selected(),"Expected descriptor [kellySlaterDescriptor] and [kdogDescriptor] to be selected");var p=o("andy-irons","Andy Irons",!1);n.setSelected(p);ok(1===n.$element.find("option:contains(Andy Irons)").length,"Expected option to be appended to <select>");ok(n.$element.find("option:contains(Andy Irons)").prop("selected"),"Expected option [Andy Irons] to be selected");ok(p.selected(),"Expected descriptor [aiDescriptor] to be selected");var a=new t({highlighted:!0,html:"<b>Actual</b> Label",label:"False, illegitimate, imposter label!",value:"10001"});n.setAllUnSelected();equal(n.getSelectedValues().length,0,"No options are selected");n.setSelected(a);equal(n.getSelectedValues().length,1,"1 option is selected");equal(n.getSelectedValues()[0],"10001","Selected value matches item");equal(a.selected(),!0,"Item reports itself as selected");equal(a.highlighted(),!1,"Item is no longer highlighted after it is selected");equal(a.label(),"Actual Label","Item label is adapted from HTML")}));test("Setting Unselected",(function(){function t(t){return e("<option />").attr("value","foo").prop("selected",!0).data("descriptor",{value:function(){return"foo"},selected:function(){return!0},removeOnUnSelect:function(){return t}})}var o=new(l.extend({init:function(){this.options={};this.$element=e("<select multiple='multiple' />");this.$element.append(t());this.$element.append(t(!0))}}));o.setUnSelected({value:function(){return"foo"}});ok(!o.$element.find("option").prop("selected"),"Expected option not to be selected");equal(o.$element.find("option").length,1,"Expected option with value removeOnUnselect to be removed from DOM")}));test("Getting All Descriptors",(function(){var t=(new(l.extend({init:function(){this.options={};this.$element=e("<select multiple='multiple' />");this.$element.append(n("1",!0));this.$element.append(n("2",!1));this.$element.append(n("3",!1));this.$element.append(n("4",!0));this.$element.append(i("group1",[n("group1-1",!0),n("group1-2",!0),n("group1-3",!1),n("group1-4",!1)]))}}))).getAllDescriptors();equal(t.length,5,"Expected 5 items (4 options & 1 optgroup");ok("1"===t[0].value(),"Expected [0] to be option 1");ok("2"===t[1].value(),"Expected [1] to be option 2");ok("3"===t[2].value(),"Expected [2] to be option 3");ok("4"===t[3].value(),"Expected [3] to be option 4");ok(t[4]instanceof o,"Expected [4] to be optgroup");equal(t[4].items().length,4,"Expected 1 option in optgroup");ok("group1-1"===t[4].items()[0].value(),"Expected [4][0] to be group1-1");ok("group1-2"===t[4].items()[1].value(),"Expected [4][1] to be group1-2");ok("group1-3"===t[4].items()[2].value(),"Expected [4][2] to be group1-3");ok("group1-4"===t[4].items()[3].value(),"Expected [4][3] to be group1-4")}));test("Getting Unselected Descriptors",(function(){var t=(new(l.extend({init:function(){this.options={};this.$element=e("<select multiple='multiple' />");this.$element.append(n("1",!0));this.$element.append(n("2",!1));this.$element.append(n("3",!1));this.$element.append(n("4",!0));this.$element.append(i("group1",[n("group1-1",!0),n("group1-2",!0),n("group1-3",!1),n("group1-4",!1)]))}}))).getUnSelectedDescriptors();equal(t.length,3,"Expected 3 items (2 options & 1 optgroup");ok("2"===t[0].value(),"Expected [0] to be option 1");ok("3"===t[1].value(),"Expected [1] to be option 4");ok(t[2]instanceof o,"Expected [2] to be optgroup");equal(t[2].items().length,2,"Expected 1 option in optgroup");ok("group1-3"===t[2].items()[0].value(),"Expected [2][0] to be group1-3");ok("group1-4"===t[2].items()[1].value(),"Expected [2][0] to be group1-4")}));test("Parsing &lt;option&gt; to ItemDescriptor",(function(){var o=new(l.extend({init:function(){this.options={}}})),n=e("<option />");n.attr({model:n}).css({backgroundImage:"url(test.png)"});var i=o._parseOption(n);ok(i instanceof t,"Expected _parseOption to return ItemDescriptor");ok(n.data("descriptor")===i,"Expected descriptor to be stored on element using jQuery.data")}));test("Removes null option",(function(){var t=new(l.extend({init:function(){this.options={removeNullOptions:!0}}})),o=e("<option value='0'>").appendTo("<select>").appendTo("#qunit-fixture");t._parseOption(o);ok(1===o.parent().length,"Expected option to only be removed if the value is less than 0");o.val("-1");t._parseOption(o);ok(0===o.parent().length,"Expected option to be removed if the value is less than 0")}));test("Selecting descriptor fires change event",(function(){var t=e("<select multiple='multiple'><option value='0'>0</option><option value='1'>1</option></select>").appendTo("body"),o=0;t.bind("change",(function(){++o}));var n=new l({element:t}),i=n.getUnSelectedDescriptors();n.setSelected(i[0]);n.setSelected(i[1]);n.setSelected(i[1]);equal(o,2)}))}));