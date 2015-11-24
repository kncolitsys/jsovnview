<cfsetting showdebugoutput="false">

<cffunction name="getCurrentURL" output="No" access="public" returnType="string">
    <cfset var theURL = getPageContext().getRequest().GetRequestUrl().toString()>
    <cfif len( CGI.query_string )><cfset theURL = theURL & "?" & CGI.query_string></cfif>
	<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cfid=[0-9]+", "")>
	<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cftoken=[^&]+", "")>
    <cfreturn theURL>
</cffunction>

<cfif structKeyExists(url, "jsonurl")>
	<cfset form.jsonurl = url.jsonurl>
	<cfset form.submit = true>
</cfif>
<cfparam name="form.jsonurl" default="">
<cfparam name="form.json" default="">

<cfset showForm = true>
<cfset errors = "">

<cfif structKeyExists(form, "submit")>
	<cfif len(trim(form.jsonurl))>
		<cftry>
			<cfhttp url="#form.jsonurl#" timeout="5">
			<cfcatch>
				<cfset errors = cfcatch.message>
			</cfcatch>
		</cftry>
		<cfif isJSON(cfhttp.filecontent)>
			<cfset ob = deserializeJSON(cfhttp.filecontent)>
		<cfelse>
			<cfset errors = "The result from the url, #form.jsonurl#, was not valid JSON.">
		</cfif>
	<cfelseif len(trim(form.json))>
		<cfset form.json = trim(form.json)>
		<cfif isJSON(form.json)>
			<cfset ob = deserializeJSON(form.json)>
		<cfelse>
			<cfset errors = "The JSON string was not valid.">
		</cfif>	
	</cfif>
	
	<cfif structKeyExists(variables, "ob")>
		<cfdump var="#ob#" label="JSON Data">
		<cfoutput>
			<cfif len(form.jsonurl)>
				<a href="getjson.cfm?jsonurl=#urlEncodedFormat(form.jsonurl)#">Reload from JSON URL</a> / 
			</cfif>
			<a href="getjson.cfm">Back to Form</a>
		</cfoutput>
		<cfset showForm = false>
	</cfif>
</cfif>

					
<cfif showForm>
	<script>
	function checkIt() {
		var jURL = document.getElementById("jsonurl");
		var json = document.getElementById("json");
		if(jURL == '' && json == '') return false;
		document.getElementById("submitButton").value="Working...";
		return true;
	}
	
	function init() {
		document.getElementById("jsonurl").focus();
	}

	</script>
	<style>
	BODY {
	 font-family: arial;
	}
	</style>
	<body onload="init()">
	<p>
	Enter either a URL to a resource that returns JSON or paste in the JSON data.
	</p>
	<cfif structKeyExists(variables, "errors")>
		<cfoutput><b>#variables.errors#</b></cfoutput>
	</cfif>
	
	<cfoutput><form action="#getCurrentURL()#" method="post" onSubmit="return checkIt()"></cfoutput>
	<b>JSON URL:</b> <input type="text" name="jsonurl" id="jsonurl" style="width:100%"><br/>
	<b>JSON String:</b></br>
	<textarea name="json" id="json" style="width:100%;height:180px"></textarea>
	<input type="submit" name="submit" id="submitButton" value="Display">
	</form>
	</body>
</cfif>

