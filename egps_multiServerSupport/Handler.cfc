<!--- 
	Licensed under the Creative Commons License, Version 3.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	http://creativecommons.org/licenses/by-sa/3.0/us/
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

	Created By Russell Brown : EmpireGP Servces
	http://blog.EmpireGPServices.com
 --->

<cfcomponent>
	<cfset variables.name = "EGPS Multi-Server Support Plugin">
	<cfset variables.id = "com.empiregpservices.mangoplugins.egps_multiserversupport">
	<cfset variables.package = "com/empiregpservices/mangoplugins/egps_multiserversupport"/>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset var path = blogid & "/" & variables.package />

			<cfset variables.blogId = blogid />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.manager = arguments.mainManager />

			<cfset variables.MultiServerSupportIPList = variables.preferencesManager.get(path,"MultiServerSupportIPList", "") />
			
		<cfreturn this/>
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfset var notice = "" />
		<cfset var owner = "egps_multiserversupport" />
		<cfset var event = "showEGPSMultiServerSupportSettings" />
		<cfset var path = variables.manager.getBlog().getId() & "/" & variables.package />

		<cfset variables.preferencesManager.put(path, "MultiServerSupportIPList", "") />
		<cfset notice = "EGPS Multi-Server Support Plugin activated.<br />" />
		<cfset notice = notice & "You can now <a href='generic_settings.cfm?event=#event#&amp;owner=#owner#&amp;selected=#event#'>Configure it</a>" />

		<cfreturn notice />
	</cffunction>
	
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfset var path = variables.manager.getBlog().getId() & "/" & variables.package />

		<cfset variables.preferencesManager.remove(path, "MultiServerSupportIPList") />

		<cfreturn />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />		
		<cfreturn />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var eventName = arguments.event.name />

		<cftry>
			<cfif listFind("allPluginsLoaded", eventName)>
				<cfset handleConfigLevelEvent() />
			<cfelseif listFind("afterPostAdd,afterPageAdd", eventName)>
				<cfreturn handleNewPostOrPageEvent(arguments.event) />
			<cfelseif listFind("afterPostUpdate,afterPostDelete", eventName)>
				<cfreturn handlePostUpdateEvent(arguments.event) />
			<cfelseif listFind("afterPageUpdate,afterPageDelete", eventName)>
				<cfreturn handlePageUpdateEvent(arguments.event) />
			<cfelseif listFind("afterCategoryAdd,afterCategoryDelete", eventName)>
				<cfreturn handleNewCategory(arguments.event) />
			<cfelseif eventName EQ "dashboardPod" AND variables.manager.isCurrentUserLoggedIn()><!--- admin dashboard event --->	
				<cfreturn handleAdminDashBoardEvent(arguments.event) />
			<cfelseif eventName EQ "settingsNav"><!--- admin nav event --->
				<cfreturn handleSettingsNavEvent(arguments.event) />
			<cfelseif eventName EQ "showEGPSMultiServerSupportSettings" AND variables.manager.isCurrentUserLoggedIn()><!--- admin event --->
				<cfreturn handleShowSettingsEvent(arguments.event) />
			</cfif>

			<cfcatch>
				<cfdump var="#cfcatch#">
				<cfabort>
			</cfcatch>
		</cftry>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleConfigLevelEvent" access="private" output="false" returntype="Void">
		<cfset var wsdlUrl = "" />
		<cfset var basePath = variables.manager.getBlog().basePath />

		<cfloop index="i" list="#variables.MultiServerSupportIPList#">
			<cfset wsdlUrl = "#i##basePath#api/CacheService.cfc?wsdl" />

			<cftry>
				<cfinvoke webservice="#wsdlUrl#" method="reloadConfig" refreshwsdl="true">
					<cfinvokeargument name="userName" value="#session.user.userName#" />
					<cfinvokeargument name="password" value="#session.user.password#" />
				</cfinvoke>

				<cfcatch>
					<!--- Ignore, most likely not logged in --->
				</cfcatch>		
			</cftry>
		</cfloop>
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleNewPostOrPageEvent" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var wsdlUrl = "" />
		<cfset var basePath = variables.manager.getBlog().basePath />

		<cfloop index="i" list="#variables.MultiServerSupportIPList#">
			<cfset wsdlUrl = "#i##basePath#api/CacheService.cfc?wsdl" />

			<cfinvoke webservice="#wsdlUrl#" method="clearAll" refreshwsdl="true" returnVariable="resetResults">
				<cfinvokeargument name="userName" value="#session.user.userName#" />
				<cfinvokeargument name="password" value="#session.user.password#" />
			</cfinvoke>
		</cfloop>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handlePostUpdateEvent" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var wsdlUrl = "" />
		<cfset var basePath = variables.manager.getBlog().basePath />

		<cfloop index="i" list="#variables.MultiServerSupportIPList#">
			<cfset wsdlUrl = "#i##basePath#api/CacheService.cfc?wsdl" />

			<cfinvoke webservice="#wsdlUrl#" method="clearPost" refreshwsdl="true" returnVariable="resetResults">
				<cfinvokeargument name="id" value="#arguments.event.data.post.id#" />
				<cfinvokeargument name="userName" value="#session.user.userName#" />
				<cfinvokeargument name="password" value="#session.user.password#" />
			</cfinvoke>
		</cfloop>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handlePageUpdateEvent" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var basePath = variables.manager.getBlog().basePath />
		<cfset var wsdlUrl = "#basePath#api/CacheService.cfc?wsdl" />

		<cfloop index="i" list="#variables.MultiServerSupportIPList#">
			<cfinvoke webservice="#i##wsdlUrl#" method="clearPage" refreshwsdl="true" returnVariable="resetResults">
				<cfinvokeargument name="id" value="#arguments.event.data.page.id#" />
				<cfinvokeargument name="userName" value="#session.user.userName#" />
				<cfinvokeargument name="password" value="#session.user.password#" />
			</cfinvoke>
		</cfloop>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleNewCategory" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var basePath = variables.manager.getBlog().basePath />
		<cfset var wsdlUrl = "#basePath#api/api.cfc?wsdl" />

		<cftry>
			<cfloop index="i" list="#variables.MultiServerSupportIPList#">
				<cfinvoke webservice="#i##wsdlUrl#" method="getCategories" refreshwsdl="false">
					<cfinvokeargument name="userName" value="#session.user.userName#" />
					<cfinvokeargument name="password" value="#session.user.password#" />
					<cfinvokeargument name="blogid" value="default" />
				</cfinvoke>
			</cfloop>
	
			<cfcatch>
				<!--- Ignore for now --->
			</cfcatch>
		</cftry>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleSettingsNavEvent" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var link = structnew() />

		<cfset link.owner = "egps_multiserversupport">
		<cfset link.page = "settings" />
		<cfset link.title = "Multi-Server Support" />
		<cfset link.eventName = "showEGPSMultiServerSupportSettings" />

		<cfset arguments.event.addLink(link)>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleAdminDashBoardEvent" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var data = "" />
		<cfset var outputData = "" />

		<cfif variables.MultiServerSupportIPList EQ "">
			<!--- add a pod warning about missin account number --->
		
			<cfsavecontent variable="outputData">
				<cfoutput>
					<p class="error">You have enabled multi-server managment but have not yet setup the servers in your group.</p>
					<p><a href="generic_settings.cfm?event=showEGPSMultiServerSupportSettings&amp;owner=egps_multiserversupport&amp;selected=showEGPSMultiServerSupportSettings">Setup Server List</a></p>
				</cfoutput>
			</cfsavecontent>			
			
			<cfset data = structnew() />
			<cfset data.title = "Multi-Server Mgr." />
			<cfset data.content = outputData />

			<cfset arguments.event.addPod(data)>
		</cfif>

		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleShowSettingsEvent" access="private" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var data = arguments.event.getData() />				
		<cfset var path = variables.manager.getBlog().getId() & "/" & variables.package />

		<cfif NOT structKeyExists(data, "message")>
			<cfreturn arguments.event />
		</cfif>

		<cfif structKeyExists(data, "externaldata") AND structKeyExists(data.externaldata,"apply")>
			<cfset variables.MultiServerSupportIPList = data.externaldata.MultiServerSupportIPList />

			<cfset variables.preferencesManager.put(path, "MultiServerSupportIPList", variables.MultiServerSupportIPList) />

			<cfset data.message.setstatus("success") />
			<cfset data.message.setType("settings") />
			<cfset data.message.settext("Server Group Updated")/>
		</cfif>

		<cfsavecontent variable="page">
			<cfinclude template="settingsForm.cfm">
		</cfsavecontent>

		<!--- change message --->
		<cfset data.message.setTitle("EGPS Multi-Server Cache Manager") />
		<cfset data.message.setData(page) />

		<cfreturn arguments.event />
	</cffunction>

</cfcomponent>