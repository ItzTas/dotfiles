AJS.test.require("jira.webresources:role-pickers",(function(){"use strict";var e=require("jira/field/role-picker-util");test("Roles formatted into ItemDescriptor",(function(){var t=[{header:"HEADER",roles:[{name:"role1",html:"<test>1</test>"},{name:"role2",html:"<test>2</test>"}]}],r=t[0],o=e.formatResponse(t);strictEqual(o.length,1,"There should only be one GroupDescriptor");var s=o[0].properties;strictEqual(s.label,r.header,"Expected provided header to be returned");var l=s.items;strictEqual(l.length,r.roles.length,"Expected all roles to be transformed into ItemDescriptor");strictEqual(l[0].properties.value,r.roles[0].name,"properties.value does not match expected name");strictEqual(l[1].properties.value,r.roles[1].name,"properties.value does not match expected name");strictEqual(l[0].properties.html,r.roles[0].html,"properties.html does not match expected name");strictEqual(l[1].properties.html,r.roles[1].html,"properties.html does not match expected name");strictEqual(l[0].properties.highlighted,!0,"Item expected to be highlighted");strictEqual(l[1].properties.highlighted,!0,"Item expected to be highlighted")}))}));