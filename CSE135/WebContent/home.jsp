<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="utf-8" /> 
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Home Page</title>
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
						<form action="cart.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Buy Shopping Cart" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue; float: right;"/>
	  					</form>
	  					<% }%>
						<br>
      					<h1>Home</h1>
      					<% 
      					if(role.equals("Owner")) { 
      					%>
  					    <form action="categories.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Categories" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
						</form>
	  					<form action="products.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Products" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
	  					</form>
	  					<%} %>
	  					<form action="browsing.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Products Browsing" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
	  					</form>
	  					<form action="order.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Product Order" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
	  					</form>
					  	<form action="confirmation.jsp">
							<input type="hidden" name="login_name" value="<%=name %>"/>
							<input type="submit" value="Confirmation" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
	  					</form>
      					<hr>
   					</header>
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
				rs.close();
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
