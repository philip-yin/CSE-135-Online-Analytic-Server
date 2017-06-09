<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Sales Analytics</title>
		<script type="text/javascript">
			function updateTable(cat){
				var xmlHttp;
				xmlHttp=new XMLHttpRequest();
				
				var responseHandler = function(){
					if(xmlHttp.readyState==4){
						//setting numbers red
						var i = 1;
						var report = "";
						while(xmlHttp.responseXML.getElementById(i) != null){
							var state_id = parseInt(xmlHttp.responseXML.getElementById(i).children[0].innerHTML);
							var product_id = parseInt(xmlHttp.responseXML.getElementById(i).children[1].innerHTML);
							var total = parseInt(xmlHttp.responseXML.getElementById(i).children[2].innerHTML);
							
							var product_pos = document.getElementById("p_" + product_id);
							var state_pos = document.getElementById("s_" + state_id);
							var cell_pos = document.getElementById(product_id + "_" + state_id);
							
							//update values and set to red
							if(product_pos != null){
								product_pos.innerHTML = parseInt(product_pos.innerHTML) + total;
								product_pos.style.color = "red";
							}
							state_pos.innerHTML = parseInt(state_pos.innerHTML) + total;
							state_pos.style.color = "red";
							if(cell_pos != null){
								cell_pos.innerHTML = parseInt(cell_pos.innerHTML) + total;
								cell_pos.style.color = "red";
							}
							
							//document.getElementById("test").innerHTML = responseDoc; 
							i++;
						}
						
						//setting columns purple
						i = 1;
						while(xmlHttp.responseXML.getElementById("pr_" + i) != null){
							var product_id = parseInt(xmlHttp.responseXML.getElementById("pr_" + i).innerHTML);
							//set header purple
							var product_pos = document.getElementById("p_" + product_id);
							product_pos.style.backgroundColor = "purple";
							
							//set cell purple
							var j = 1;
							while(j <= 56){
								var cell_id = product_id + "_" + j;
								var cell_pos = document.getElementById(cell_id);
								cell_pos.style.backgroundColor = "purple";
								j++
							}
							i++;
						}
						//report nonexist columns
						
						i = 1;
						var flag = 0;
						while(xmlHttp.responseXML.getElementById("re_" + i) != null){
							flag = 1;
							var product_name = xmlHttp.responseXML.getElementById("re_" + i).innerHTML;
							//append string
							report = report + " " + product_name;
							i++;
						}
						if(flag == 1){
							report = report + " is(are) now in top-50 but not shown yet. Press Run Query button to update page.";
						}
						document.getElementById("report").innerHTML = report;
						document.getElementById("report").style.color = "red";
						
					}
				}
				
				xmlHttp.onreadystatechange = responseHandler ;
				xmlHttp.open("GET","log.jsp?cat=" + cat,true);
				xmlHttp.send();
			}
		</script>
	</head>
	<body>
			<p id="report"></p>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
			if(session.getAttribute("roleName") != null) {
				String role = session.getAttribute("roleName").toString();
				if("owner".equalsIgnoreCase(role) == true){
			
				//setting variables
			
				String cat = request.getParameter("filter");
				
				int filter;
				int cat_id = 0;
				
				if(cat == null || cat.equals("all")){
					filter = 0;
				}
				else{
					filter = 1;
				}
				
				
				Connection conn;
				Statement stmt4, stmt6;
				PreparedStatement stmt, stmt2, stmt3, stmt5, stmt7;
				ResultSet rs, rs2, rs3, rs4, rs6;
				
				try {
					// Registering Postgresql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/CSE135", "postgres", "cse135");
					
					//setting up all statements
					
					stmt2 = conn.prepareStatement("select * from temp2 where state_name = ?", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
					
					if(filter == 0){
						stmt = conn.prepareStatement("select state_name, id, sum(total) as total from temp1 group by state_name, id order by total desc", ResultSet.TYPE_SCROLL_SENSITIVE, 
	                            ResultSet.CONCUR_UPDATABLE);
						
						stmt3 = conn.prepareStatement("select product_name, id, sum(total) as total from temp3 group by product_name, id order by total desc limit 50", ResultSet.TYPE_SCROLL_SENSITIVE, 
	                            ResultSet.CONCUR_UPDATABLE);
					}
					else{
						stmt = conn.prepareStatement("select state_name, id, sum(total) as total from temp1 where category_id = ? group by state_name, id order by total desc", ResultSet.TYPE_SCROLL_SENSITIVE, 
	                            ResultSet.CONCUR_UPDATABLE);
						
						stmt3 = conn.prepareStatement("select product_name, id, sum(total) as total from temp3 where category_id = ? group by product_name, id order by total desc limit 50", ResultSet.TYPE_SCROLL_SENSITIVE, 
	                            ResultSet.CONCUR_UPDATABLE);
					}
					
					
					stmt4 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
					//move log table data to temp1-3 tables
					stmt6 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
					
					rs6 = stmt6.executeQuery("select * from log");
					
					//update temp1
					stmt5 = conn.prepareStatement("update temp1 set total = total + ? where id = ? and category_id = ?");
					stmt7 = conn.prepareStatement("insert into temp1 values (?, ?, ?, ?)");
					
					while(rs6.next()){
						int prod_id = rs6.getInt("product_id");
						int per_id = rs6.getInt("person_id");
						int add = rs6.getInt("total");
						
						//helper query to get category of product
						PreparedStatement tstmt = conn.prepareStatement("select category_id from product where id = ?");
						tstmt.setInt(1, prod_id);
						ResultSet trs = tstmt.executeQuery();
						trs.next();
						int category = trs.getInt("category_id");
						
						//helper query to get the state_name and state_id of person
						PreparedStatement t3stmt = conn.prepareStatement("select s.state_name, s.id from state s, person p where s.id = p.state_id and p.id = ?");
						t3stmt.setInt(1, per_id);
						ResultSet t3rs = t3stmt.executeQuery();
						t3rs.next();
						String state_name = t3rs.getString("state_name");
						int state_id = t3rs.getInt("id");
						
						//helper query to detect if state-category combination exist
						PreparedStatement t2stmt = conn.prepareStatement("select * from temp1 where id = ? and category_id = ?");
						t2stmt.setInt(1, state_id);
						t2stmt.setInt(2, category);
						ResultSet t2rs = t2stmt.executeQuery();
						
						
						//if this state-category combination exist, add value
						if(t2rs.next()){
							stmt5.setInt(1, add);
							stmt5.setInt(2, state_id);
							stmt5.setInt(3, category);
							stmt5.executeUpdate();
						}
						//if this state-category combination does not exist, create this combination
						else{
							stmt7.setString(1, state_name);
							stmt7.setInt(2, state_id);
							stmt7.setInt(3, category);
							stmt7.setInt(4, add);
							stmt7.executeUpdate();
						}
						trs.close();
						t2rs.close();
						tstmt.close();
						t2stmt.close();
					}
					rs6.beforeFirst();
					//update temp2
					stmt5 = conn.prepareStatement("update temp2 set total = total + ? where product_id = ? and state_name = ?");
					while(rs6.next()){
						int prod_id = rs6.getInt("product_id");
						int per_id = rs6.getInt("person_id");
						int add = rs6.getInt("total");
						//helper query to get state_name
						PreparedStatement tstmt = conn.prepareStatement("select s.state_name from state s, person p where s.id = p.state_id and p.id = ?");
						tstmt.setInt(1, per_id);
						ResultSet trs = tstmt.executeQuery();
						trs.next();
						String state_name = trs.getString("state_name");
						stmt5.setInt(1, add);
						stmt5.setInt(2, prod_id);
						stmt5.setString(3, state_name);
						stmt5.executeUpdate();
						trs.close();
						tstmt.close();
					}
					rs6.beforeFirst();
					//update temp3
					stmt5 = conn.prepareStatement("update temp3 set total = total + ? where id = ?");
					while(rs6.next()){
						int prod_id = rs6.getInt("product_id");
						int add = rs6.getInt("total");
						stmt5.setInt(1, add);
						stmt5.setInt(2, prod_id);
						stmt5.executeUpdate();
					}
					
					//delete data from log table
					stmt6.executeUpdate("delete from log");
					
					rs4 = stmt4.executeQuery("select category_name, id from category");
					if(filter == 1){
						while(rs4.next()){
							if(rs4.getString("category_name").equals(cat)){
								cat_id = rs4.getInt("id");
								break;
							}
						}
						rs4.beforeFirst();
					}
					//create table
					%>
					
					<table border = "1">
						<tr><th></th>
						<%

						if(filter == 0){
							rs3 = stmt3.executeQuery();
							rs = stmt.executeQuery();
						}
						else{
							stmt3.setInt(1, cat_id);
							rs3 = stmt3.executeQuery();
							stmt.setInt(1, cat_id);
							rs = stmt.executeQuery();
						}

						while(rs3.next()){
							String str = rs3.getString("product_name");
							if(str.length() > 10)
								str = str.substring(0, 10);
							%><th><b><%=str%></b><br>(<b id="p_<%=rs3.getInt("id")%>"><%=rs3.getInt("total")%></b>)</th><%
						}
						%>
						</tr>
						<% 
						
						while (rs.next()) {
							%><tr><td><b><%=rs.getString("state_name")%></b>(<b id="s_<%=rs.getInt("id")%>"><%=rs.getInt("total") %></b>)</td><%
							stmt2.setString(1, rs.getString("state_name"));
							rs2 = stmt2.executeQuery();
							rs3.beforeFirst();
							//the state has purchase
							if(rs2.next()){
								while(rs3.next()){
									rs2.beforeFirst();
									int cell_id = rs3.getInt("id");
									int flag = 0;
									//search rs2 for this id
									while(rs2.next()){
										if(rs2.getInt("product_id") == cell_id){
											%><td id="<%=rs3.getInt("id")+ "_" + rs.getInt("id")%>"><%=rs2.getInt("total")%></td><%
											flag = 1;
											break;
										}
									}
									if(flag == 0){
										%><td id="<%=rs3.getInt("id") + "_" + rs.getInt("id")%>">0</td><%
									}
								}
							}
							//state does not have purchase
							else{
								while(rs3.next()){
									%><td id="<%=rs3.getInt("id") + "_" + rs.getInt("id")%>">0</td><%
								}
							}
							%></tr><%
						}
					%>
					</table>
					<br>
					<br>
					
				
					<form action="analytics.jsp" method="GET">
												
						<select name ="filter">
							<%
							if(cat == null || cat.equals("all")){
								%>
								<option value="all" selected="selected">All</option>
								<%
							}
							else{
								%>
								<option value="all">All</option>
								<%
							}
							while(rs4.next()){
								if(rs4.getString("category_name").equals(cat)){
									%>
									<option value="<%=rs4.getString("category_name")%>" selected="selected"><%=rs4.getString("category_name") %></option>
									<%
								}
								else{
									%>
									<option value="<%=rs4.getString("category_name")%>"><%=rs4.getString("category_name") %></option>
									<%
								}
							}
							rs.close();
							rs3.close();
							rs4.close();
							rs6.close();
							stmt.close();
							stmt2.close();
							stmt3.close();
							stmt4.close();
							stmt5.close();
							stmt6.close();
							stmt7.close();
							%>
						</select>
						
						<input type="submit" value="Run Query"/>
					</form>
					
					<br>
					
					<input onclick="updateTable(<%=cat_id%>)" type="button" value ="refresh"/>
					<br>
					<br>
					
					<%
					// Close the ResultSet
					//rs.close();
					// Close the Statement
					//stmt.close();
					// Close the Connection
					//conn.close();
				} catch (SQLException e) {
					%><%= e %><%
				}
	
				} 
				else { %>
					<h3>This page is available to owners only</h3>
				<%
				}
			}
			else { %>
					<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
			<%} %>
		
	</body>
</html>