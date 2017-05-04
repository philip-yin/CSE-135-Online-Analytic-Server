<!DOCTYPE HTML>
<html>
	<head><title>Product Browsing</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
				String name = request.getParameter("login_name");
				String category = request.getParameter("category");
				String item = request.getParameter("item");

				Connection conn;
				Statement stmt;
				ResultSet rs;
				PreparedStatement pstmt;
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
						
							rs = stmt.executeQuery("SELECT * FROM category");
							%>
							<form method="GET" action="productbrowsing.jsp" >
								<input type="hidden" name="login_name" value="<%=name %>"/>
								Filter by Category:<br>
								<% while (rs.next() ) { %>
									<input type="radio" name="category" value="<%=rs.getString("name")%>"><%=rs.getString("name")%><br>
								<% } %>
								<input type="radio" name="category" value="">All Products<p>
								Search Product: <input type="text" size="20" name="item"/> <p>
								<input type="submit" value="Search"/>
							</form>			
							<%
							session.setAttribute("category", category);
							session.setAttribute("item", item);
	
							if (category != "" && category != null && item != "" && item != null) {
								rs = stmt.executeQuery("SELECT * FROM product WHERE cat='" + category + "' AND name LIKE '%" + item + "%'"); %>
								Filtering by: <%= category %> and <%= item %> <p>
							<% }
							else if (category != "" && category != null) {
								rs = stmt.executeQuery("SELECT * FROM product WHERE cat='" + category + "'"); %>
								Filtering by: <%= category %> <p>
							<% }
							else if (item != "" && item != null) {
								rs = stmt.executeQuery("SELECT * FROM product WHERE name LIKE '%" + item + "%'"); %>
								Filtering by: <%= item %> <p>
							<% } else {
								rs = stmt.executeQuery("SELECT * FROM product"); %>
								Filtering by: All Products <p>
							<%}
							%>
							<table>
								<tr>
									<th>SKU</th>
									<th>Name</th>
									<th>Price</th>
									<th>Category</th>
								</tr>
								<%-- Iterate over the ResultSet --%>
								<% while ( rs.next() ) { %>
									<tr>
										<td><%=rs.getString("sku")%></td> 
										<td><%=rs.getString("name")%></td>
										<td><%=rs.getInt("price")%></td>
										<td><%=rs.getString("cat")%></td>
										<td>
											<form method="GET" action="productorder.jsp">
												<input type="hidden" name="login_name" value="<%=name %>"/>
												<input type="submit" value="Order"/>
												<input type="hidden" name="order_item" value=<%=rs.getString("sku")%> />
											</form>
										</td>
									</tr>
								<% } %>
							</table>
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