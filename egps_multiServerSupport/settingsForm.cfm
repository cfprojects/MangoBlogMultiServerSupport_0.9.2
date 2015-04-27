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

<cfset currentIps = variables.MultiServerSupportIPList />

<cfoutput>

<form method="post" action="#cgi.script_name#">

	<p>
		<label for="MultiServerSupportIPList">Please Add a base IP or Host with server protocol for each server in your farm/collection</span>

		<table style="width: 400px; border: 0;"><tr>
			<td valign="top" style="text-align: left; border: 0;">
				<span class="field">
					<cfloop index="i" from="1" to="#listLen(currentIps)#">
						<input type="text" name="MultiServerSupportIPList" id="MultiServerSupportIP#i#" value="#listGetAt(currentIps, i)#" size="40" /><br>
					</cfloop>
					<cfloop index="i" from="#i+1#" to="#iif(i EQ 1, 5, i + 3)#">
						<input type="text" name="MultiServerSupportIPList" id="MultiServerSupportIP#i#" value="" size="40" /><br>
					</cfloop>
				</span>

				<div class="actions" style="text-align: right;">
					<input type="submit" class="primaryAction" value="Save Changes"/>
					<input type="hidden" value="event" name="action" />
					<input type="hidden" value="showEGPSMultiServerSupportSettings" name="event" />
					<input type="hidden" value="true" name="apply" />
					<input type="hidden" value="egps_multiserversupport" name="selected" />
				</div>
			</td>
			<td valign="top" style="text-align: left; padding-left: 40px; border: 0;">
				<strong>Examples</strong><br>
				<ul>
					<li>http://100.myserver.com</li>
					<li>http://101.myserver.com</li>
					<li>http://103.myserver.com</li>
				</ul>
				OR
				<ul>
					<li>https://173.194.33.104</li>
					<li>https://173.194.33.106</li>
					<li>https://173.194.33.107</li>
				</ul>
			</td>
		</tr></table>
	</p>

</form>



</cfoutput>