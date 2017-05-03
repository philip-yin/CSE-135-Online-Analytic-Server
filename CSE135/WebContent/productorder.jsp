<html>
	<head><title>Product Order</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
				String order_item = request.getParameter("order_item");
			%>
			<%--get user--%>
			<%
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
					"jdbc:postgresql://localhost/postgres?" +
					"user=postgres&password=cse135");
			%>
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
					pstmt.setInt(4, 1);
					pstmt.executeUpdate();
				}
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
			<form method="GET" action="productorder.jsp">
				Product: <%=order_item%> <p>
				Enter Amount: <input type="text" size="20" name="item_num"/> <p>
				<input type="submit" value="Put in cart"/>
				<input type="hidden" name="order_item" value="<%=order_item%>" />
			</form> <p>
			<a href="productbrowsing.jsp">Return to browsing products<a>
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