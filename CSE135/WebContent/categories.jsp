<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="utf-8" /> 
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Home Page</title>
    <script src="javascript/categories.js"></script>
  </head>
  <body>
  	<%@ page import="java.sql.*" %>
    <%
		String name = request.getParameter("login_name");
		
		try {
			//Registering Postgresql JDBC driver
			Class.forName("org.postgresql.Driver");
			Connection conn = null;
			conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/CSE135_DB", "postgres","cse135");
			Statement stmt = conn.createStatement();
			ResultSet rs;
			if(name == ""){
				%>
				<p> Please provide your name. </p>
				
				<a href="login.html"> Log in again </a>
				<br>
				<a href="signup.html"> Sign up if you don't have an account. </a>
				<%
			}
			else{

				rs = stmt.executeQuery("SELECT * FROM USERS WHERE NAME = '" + name + "'");
				if (rs.next()){
					String role = rs.getString("role");
					%>
					<header>
						<h3>Hello <%=name%></h3>
						<%
						if(role.equals("Customer")){
						%>
						<h3>This page is available to owners only!</h3>
	  					<% }%>
						<br>
      					<% 
      					if(role.equals("Owner")) { 
      					%>
  					    <form action="categories.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Categories" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
						</form>
	  					<form action="product.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Products" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
	  					</form>
	  					<%} %>
	  					<form action="productbrowsing.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Products Browsing" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
	  					</form>
      					<hr>
   					</header>
					<p> all categories: <p>
					<div>
						<input type="text" value="Category Name" readonly/>
						<input type="text" value="Category Description" style="margin-left: 30px; vertical-align: text-top;"readonly/>
					</div>
					<br>
					<div>
						<input type="text" id="new_name" value=""/>
						<textarea id="new_des" rows="4" cols="50" style="margin-left: 30px; vertical-align: text-top;"></textarea>
						<form action="categories.jsp" style="display:inline;">	
							<input type="hidden" name="login_name" value="<%=name %>"/>							
							<input type="hidden" name="cat_name" id="insert_name" value=""/>							
							<input type="hidden" name="cat_des" id="insert_des" value=""/>
							<input type="hidden" name="action" value="insert"/>
							<input type="submit" id="insert" value="Insert"/>
						</form>
					</div>
					<%
					//update categories if needed
					String action = request.getParameter("action");
					String action_name = request.getParameter("cat_name");
					String action_des = request.getParameter("cat_des");
					String action_prev = request.getParameter("prev_name");
					rs = stmt.executeQuery("SELECT * FROM CATEGORY WHERE NAME = '" + action_name + "'");
					
					if(action!= null){
						if(action.equals("insert")){
							if(rs.next() || action_name == "" || action_des == ""){
								%>
								<p style="color: red;"> Data modification failure </p>
								<%
							}
							else{
								stmt.executeUpdate("INSERT INTO CATEGORY(name, description) VALUES ('" + action_name + "', '" + action_des + "')");
							}
						}
						else if(action.equals("update")){
							if(rs.next() || action_name == "" || action_des == "" || action_prev == ""){
								if(action_name.equals(action_prev)){
									stmt.executeUpdate("UPDATE CATEGORY SET name = '" + action_name + "', description = '" + action_des + "' WHERE name = '" + action_prev + "'");
								}
								else{
									%>
									<p style="color: red;"> Data modification failure </p>
									<%
								}
							}
							else{
								rs = stmt.executeQuery("SELECT * FROM CATEGORY WHERE NAME = '" + action_prev + "'");
								if(!rs.next()){
									%>
									<p style="color: red;"> Data modification failure </p>
									<%
								}
								else{
									stmt.executeUpdate("UPDATE CATEGORY SET name = '" + action_name + "', description = '" + action_des + "' WHERE name = '" + action_prev + "'");
								}
							}
						}
						else if(action.equals("delete")){
							if(!rs.next() || action_name == ""){
								%>
								<p style="color: red;"> Data modification failure </p>
								<%
							}
							else{
								stmt.executeUpdate("DELETE FROM CATEGORY WHERE name = '" + action_name + "'");
							}
						}
					}
					//display all categories
					
					rs = stmt.executeQuery("SELECT * FROM CATEGORY");
	
					while(rs.next()){
						String cat_name = rs.getString("name");
						String cat_des = rs.getString("description");
						%>
						<div>
							<input type="text" class="update_names" value="<%=cat_name%>"/>
							<textarea class="update_deses" rows="4" cols="50" style="margin-left: 30px; vertical-align: text-top;"><%=cat_des %></textarea>
							<form action="categories.jsp" style="display:inline;">	
								<input type="hidden" name="login_name" value="<%=name %>"/>		
								<input type="hidden" name="prev_name" value="<%=cat_name%>"/>				
								<input type="hidden" class="update_name" name="cat_name" value=""/>							
								<input type="hidden" class="update_des" name="cat_des" value=""/>
								<input type="hidden" name="action" value="update"/>
								<input type="submit" class="update" value="Update"/>
							</form>
							<form action="categories.jsp" style="display:inline;">
								<input type="hidden" name="login_name" value="<%=name %>"/>
								<input type="hidden" class="delete_name" name="cat_name" value=""/>
								<input type="hidden" name="action" value="delete"/>
								<input type="submit" class="delete" value="Delete"/>
							</form>
						</div>
						<%
					}
					%>
					<br><br>
					<%
				}
				else{
					%>
					<p> Log In failed! The provided name <%= name %> is not known <p>
					
					<a href="login.html"> Log in again </a>
					<br>
					<a href="signup.html"> Sign up if you don't have an account. </a>
					<%
				}
			}			
			stmt.close();
			conn.close();
			
		}catch(Exception e){
			e.printStackTrace();
			%>
			<%= e %>
			<%
		}
    %>
  </body>
</html>
