<html>
	<head><title>Product Order</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
				String name = request.getParameter("login_name");
				String order_item = request.getParameter("order_item");
	
				Connection conn;
				Statement stmt;
				ResultSet rs;
				ResultSet rsname;
				PreparedStatement pstmt;
				int thing_id = 0;
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
							String item_num = request.getParameter("item_num");
							rs = conn.createStatement().executeQuery("SELECT COUNT(*) as total FROM cart");
							while ( rs.next() ) {
								thing_id = rs.getInt("total");
							}
							if (item_num != null && Integer.parseInt(item_num) > 0) {
								pstmt = conn.prepareStatement("INSERT INTO cart VALUES (?, ?, ?, ?)");
								pstmt.setInt(1, (thing_id + 1));
								pstmt.setInt(2, Integer.parseInt(item_num));
								pstmt.setString(3, order_item);
								pstmt.setInt(4, user_id);
								pstmt.executeUpdate();
							}


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
							<form method="GET" action="productorder.jsp">
								<input type="hidden" name="login_name" value="<%=name %>"/>
								Product: <%=order_item%> <p>
								Enter Amount: <input type="text" size="20" name="item_num"/> <p>
								<input type="submit" value="Put in cart"/>
								<input type="hidden" name="order_item" value="<%=order_item%>" />
							</form> <p>
							<form action="productbrowsing.jsp">
									<input type="hidden" name="login_name" value="<%=name %>"/>
									<input type="submit" value="Return to browsing products" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
							</form>
							<form action="buycart.jsp">
								<input type="hidden" name="login_name" value="<%=name %>"/>
								<input type="submit" value="Proceed to checkout" style="border: none; background-color: white; text-decoration:underline; cursor: pointer; color: blue;"/>
							<form>
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