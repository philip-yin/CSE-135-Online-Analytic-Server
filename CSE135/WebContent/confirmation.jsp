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
			%>
			<%
				// Create the statement
				stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT p.sku sku, c.amount amount, p.price price FROM cart c, product p WHERE user_id=1 AND p.sku=c.product_id");
				rscount = conn.createStatement().executeQuery("SELECT COUNT(*) as total FROM purchase");
				while ( rscount.next() ) {
					thing_id = rscount.getInt("total");
				}
			%>
			<% while ( rs.next() ) {
				thing_id = thing_id + 1;
				pstmt = conn.prepareStatement("INSERT INTO purchase VALUES (?, ?, ?, ?, ?, ?)");
				pstmt.setInt(1, thing_id);
				pstmt.setString(2, rs.getString("sku"));
				pstmt.setInt(3, rs.getInt("amount"));
				pstmt.setInt(4, rs.getInt("price"));
				pstmt.setDate(5, java.sql.Date.valueOf(java.time.LocalDate.now()));
				pstmt.setInt(6, 1);
				pstmt.executeUpdate();
			} %>
			<%
				rs = stmt.executeQuery("SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=1 AND p.sku=c.product_id");
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
				rs = stmt.executeQuery("SELECT SUM(a.amount*a.price) total FROM (SELECT p.name product, c.amount amount, p.price price FROM cart c, product p WHERE user_id=1 AND p.sku=c.product_id) a");
			%>

			Total cost: 
			<% while (rs.next() ) { %>
				<%=rs.getInt("total")%>
			<% } %> <p>
			
			<%
				stmt.executeUpdate("DELETE FROM cart WHERE user_id=1");
			%>
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