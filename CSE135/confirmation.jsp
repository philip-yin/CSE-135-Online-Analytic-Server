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
				PreparedStatement pstmt;
				int thing_id = 0;
				ResultSet rscount;
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
						
							rs = stmt.executeQuery("SELECT p.sku sku, c.amount amount, p.price price FROM cart c, product p WHERE user_id=" + user_id + " AND p.sku=c.product_id");
							rscount = conn.createStatement().executeQuery("SELECT COUNT(*) as total FROM purchase");
							while ( rscount.next() ) {
								thing_id = rscount.getInt("total");
							}
							
							while ( rs.next() ) {
								thing_id = thing_id + 1;
								pstmt = conn.prepareStatement("INSERT INTO purchase VALUES (?, ?, ?, ?, ?, ?)");
								pstmt.setInt(1, thing_id);
								pstmt.setString(2, rs.getString("sku"));
								pstmt.setInt(3, rs.getInt("amount"));
								pstmt.setInt(4, rs.getInt("price"));
								pstmt.setDate(5, java.sql.Date.valueOf(java.time.LocalDate.now()));
								pstmt.setInt(6, user_id);
								pstmt.executeUpdate();
							} 
							 
							rs = stmt.executeQuery("SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=" + user_id + " AND p.sku=c.product_id");
							%>
							What you purchased: <p>
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
							
							<%
								stmt.executeUpdate("DELETE FROM cart WHERE user_id=" + user_id);
							%>
							<form action="productbrowsing.jsp">
									<input type="hidden" name="login_name" value="<%=name %>"/>
									<input type="submit" value="Return to browsing products" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
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