<html>
  <head>
    <title>signup status</title>
  </head>
  <body>
  	<%@ page import="java.sql.*" %>
    <%
		String name = request.getParameter("name");
		String age = request.getParameter("age");
		String role = request.getParameter("role");
		String state = request.getParameter("state");
		
		try {
			//Registering Postgresql JDBC driver
			Class.forName("org.postgresql.Driver");
			Connection conn = null;
			conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/CSE135_DB", "postgres","cse135");
			Statement stmt = conn.createStatement();
			ResultSet rs;
			if(name == "" || age == "" || role == "" || state==""){
				%>
				<p> Your signup failed! please fill in all your info</p>
				
				<a href="index.html"> Go Sign Up again! </a>
				<%
			}
			else{

				rs = stmt.executeQuery("SELECT * FROM USERS WHERE NAME = '" + name + "'");
				if (rs.next()){
					%>
					<p> Your signup failed! user name already in use. </p>
					
					<a href="index.html"> Go Sign Up again! </a>
					<%
				}
				else{
					stmt.executeUpdate("INSERT INTO USERS(AGE, ROLE, NAME, STATE) VALUES('" + age + "', '" + role + "', '" + name + "','" + state + "')");
					%>
					<p> You have successfully signed up!</p>
					
					<a href = "login.html"> Go to Log In</a>
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