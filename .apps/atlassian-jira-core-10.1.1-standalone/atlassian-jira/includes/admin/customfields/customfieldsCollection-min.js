define("jira/customfields/customfieldsCollection",["jira/backbone/backbone-paginator","jira/moment","wrm/context-path","underscore"],(function(e,t,r,s){"use strict";var n=new Intl.NumberFormat;return e.extend({url:r()+"/rest/api/2/customFields",state:{pageSize:50},queryParams:{currentPage:"startAt",pageSize:"maxResults",search:function(){return this.searchTerm},projectIds:function(){return this.getFilterValues("projectIds")},types:function(){return this.getFilterValues("types")},screenIds:function(){return this.getFilterValues("screenIds")},sortOrder:function(){return this.getFilterValues("sortOrder")},sortColumn:function(){return this.getFilterValues("sortColumn")},lastValueUpdate:function(){return this.getFilterValues("lastValueUpdate")}},filters:{projectIds:[],types:[],screenIds:[],sortOrder:null,sortColumn:null,lastValueUpdate:null},parseState:function(e){return{totalRecords:e.total}},parseRecords:function(e){var r=e.values;return s.isArray(r)?r.map((function(e){return s.extend(e,{formattedIssuesWithValue:e.issuesWithValue&&n.format(e.issuesWithValue),formattedLastValueUpdate:e.lastValueUpdate&&t(e.lastValueUpdate).format("MMM DD, YYYY")})})):r},getFilterValues:function(e){return Number.isInteger(this.filters[e])?this.filters[e]:s.isEmpty(this.filters[e])?void 0:this.filters[e]},resetDeleteData:function(){this.each((function(e){e.set("isSelected",!1)}))},getSelectableModels:function(){return this.models.filter((function(e){return!e.get("isLocked")&&!e.get("isManaged")}))}})}));