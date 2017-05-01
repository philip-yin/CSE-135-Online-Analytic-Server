<html>
	<head><title>why aren't u fuking working</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
				Connection conn;
				Statement stmt;
				ResultSet rs;
				try {
					// Registering Postgresql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/postgres?" +
					"user=postgres&password=cse135");
			%>
			<%
				// Create the statement
				stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT * FROM category");
			%>
			<form method="GET" action="product.jsp">
				<input type="hidden" name="category" />
			</form>
			
			<% while ( rs.next() ) { %>
				<a href="product.jsp?category=<%=rs.getString("name")%>"><%=rs.getString("name")%><a><p> 
			<% } %>
			
			<%
				String category = request.getParameter("category");
				session.setAttribute("category", category);
			%>
			<form method="GET" action="product.jsp">
				Search Product: <input type="text" size="20" name="item"/><p />
				<input type="submit" value="Search"/>
			</form>
			<%
				String item = request.getParameter("item");
				session.setAttribute("item", item);
				if (category != "" && category != null) {
					rs = stmt.executeQuery("SELECT * FROM product WHERE cat='" + category + "'"); %>
					Filtering by: <%= category %> <p>
				<% }
				if (item != "" && item != null) {
					rs = stmt.executeQuery("SELECT * FROM product WHERE name LIKE '%" + item + "%'"); %>
					Filtering by: <%= item %> <p>
				<% } else {
					rs = stmt.executeQuery("SELECT * FROM product"); %>
					Filtering by: All Products <p>
				<%}
			%>
			<table>
				<tr>
					<th>ID</th>
					<th>Name</th>
					<th>SKU</th>
					<th>Price</th>
				</tr>
				<%-- Iterate over the ResultSet --%>
				<% while ( rs.next() ) { %>
					<tr>
						<td><%=rs.getInt("id")%></td>
						<td><%=rs.getString("name")%></td>
						<td><%=rs.getString("sku")%></td>
						<td><%=rs.getInt("price")%></td>
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
				} catch (SQLException e) {}
			%>
		</td>
	</tr></table></body>
</html>