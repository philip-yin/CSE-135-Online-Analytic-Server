<html>
	<head><title>Buy Shopping Cart</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%--get user--%>
			<%
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
			%>
			<%
				// Create the statement
				stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=1 AND p.sku=c.product_id");
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
				rs = stmt.executeQuery("SELECT SUM(a.amount*a.price) total FROM (SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=1 AND p.sku=c.product_id) a");
			%>

			Total cost: 
			<% while (rs.next() ) { %>
				<%=rs.getInt("total")%>
			<% } %> <p>
			
			<form method="GET" action="confirmation.jsp">
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
				} catch (SQLException e) {}
			%>
		</td>
	</tr></table></body>
</html>