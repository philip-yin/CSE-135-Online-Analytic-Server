<!DOCTYPE HTML>
<html>
  <head>
    <title>log in status</title>
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
					
					%>
					<header>
						<h3>Hello <%=name %></h3>
					</header>
					<br>
					<form action="home.jsp">
						<input type="hidden" name="login_name" value="<%=name %>"/>
						<input type="submit" value="You have successfully Logged In! Go to Home page." style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
					</form>
					<%
				}
				else{
					%>
					<p> Log In failed! The provided name <%=name %>is not known <p>
					
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