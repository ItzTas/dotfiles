define("jira/customfields/customfieldsFilterProjectCollection",["jira/backbone-1.3.3","wrm/context-path","jira/util/formatter"],(function(e,t,a){"use strict";return e.Collection.extend({url:t()+"/rest/api/2/project",id:"projectIds",name:"projects",parse:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[],r="".concat(t(),"/secure/projectavatar?size=xsmall"),i=e.map((function(e){return{id:e.id,name:"".concat(e.name," (").concat(e.key,")"),description:e.name,avatarUrl:e.avatarUrls&&e.avatarUrls["16x16"]?e.avatarUrls["16x16"]:r}}));i.unshift({id:"admin.issuefields.customfields.global.all.projects",name:a.I18n.getText("admin.issuefields.customfields.global.all.projects"),description:"",avatarUrl:r});return i}})}));