<html>
	<head><title>Buy Shopping Cart</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
				String name = request.getParameter("login_name");
				Connection conn;
				Statement stmt;
				ResultSet rs;
				ResultSet rsname;
				try {
					// Registering Postgresql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost:5432/CSE135_DB",
					"postgres", "cse135");
	
					if(name == ""){
						%>
						<p> Please provide your name. </p>
						
						<a href="login.html"> Log in again </a>
						<br>
						<a href="signup.html"> Sign up if you don't have an account. </a>
						<%
					}
					else{
						// Create the statement
						stmt = conn.createStatement();
						rs = stmt.executeQuery("SELECT * FROM USERS WHERE NAME = '" + name + "'");
						if (rs.next()){
							int user_id = rs.getInt("id");
							%>
							<header>
								<h3>Hello <%=name%></h3>
								<form action="home.jsp">
									<input type="hidden" name="login_name" value="<%=name %>"/>
									<input type="submit" value="Back to home page" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
								</form>
								<hr>		
							</header>
							<%
						
							rs = stmt.executeQuery("SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=" + user_id + " AND p.sku=c.product_id");
							%>

							Current items in cart: <p>
							<table>
								<tr>
									<th>Item</th>
									<th>Amount</th>
									<th>Price ea.<th>
								</tr>
								<%-- Iterate over the ResultSet --%>
								<% while ( rs.next() ) { %>
									<tr>
										<td><%=rs.getString("product")%></td>
										<td><%=rs.getInt("amount")%></td>
										<td><%=rs.getInt("price")%></td>
									</tr>
								<% } %>
							</table> <p>
							<% 
								rs = stmt.executeQuery("SELECT SUM(a.amount*a.price) total FROM (SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=" + user_id + " AND p.sku=c.product_id) a");
							%>
				
							Total cost: 
							<% while (rs.next() ) { %>
								<%=rs.getInt("total")%>
							<% } %> <p>
							
							<form method="GET" action="confirmation.jsp">
								<input type="hidden" name="login_name" value="<%=name %>"/>
								Enter your credit card ;): <input type="text" size="20" /> <p>
								<input type="submit" value="Purchase"/>
							</form>
							<%
							// Close the ResultSet
							rs.close();
							// Close the Statement
							stmt.close();
							// Close the Connection
							conn.close();
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
				} catch (SQLException e) {}
			%>
		</td>
	</tr></table></body>
</html>