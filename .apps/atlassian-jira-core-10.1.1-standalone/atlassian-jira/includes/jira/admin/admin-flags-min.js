require(["jira/util/logger","wrm/data","jquery","jira/flag"],(function(a,s,e,i){"use strict";e((function(){var c=s.claim("jira.core:user-message-flags-data.adminLockout")||{};if(c.noprojects){var n=JIRA.Templates.Flags.Admin,r=n.adminIssueAccessFlagTitle({}),l=n.adminIssueAccessFlagBody({manageAccessUrl:c.manageAccessUrl}),g=i.showWarningMsg(r,l,{dismissalKey:c.flagId});e(g).find("a").on("click",(function(){g.dismiss()}))}a.trace("admin.flags.done")}))}));