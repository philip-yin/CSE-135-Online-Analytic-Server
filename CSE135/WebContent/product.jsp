<html>
	<head><title>Products</title></head>
	<body><table><tr>
		<td></td>
		<td>
			<%-- Import the java.sql package --%>
			<%@ page import="java.sql.*" %>
			<%
				String category = request.getParameter("category");
				String item = request.getParameter("item");

			%>
						
			<%
				session.setAttribute("category", category);
				session.setAttribute("item", item);
			%>
			<%
				Connection conn;
				Statement stmt;
				ResultSet rs;
				PreparedStatement pstmt;
				try {
					// Registering Postgresql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/postgres?" +
					"user=postgres&password=cse135");
			%>
			<%
				String add = request.getParameter("add");
				if (add != null && add.equals("insert")) {
					pstmt = conn.prepareStatement("INSERT INTO product VALUES (?, ?, ?, ?)");
					pstmt.setString(1, request.getParameter("item_sku"));
					pstmt.setString(2, request.getParameter("item_name"));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("item_price")));
					pstmt.setString(4, request.getParameter("item_cat"));
					pstmt.executeUpdate();
				}
			%>
			<%
				// Create the statement
				stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT * FROM category");
			%>
			<form method="GET" action="product.jsp" >
				Filter by Category:<br>
				<% while (rs.next() ) { %>
					<input type="radio" name="category" value="<%=rs.getString("name")%>"><%=rs.getString("name")%><br>
				<% } %>
				<input type="radio" name="category" value="">All Products<p>
				Search Product: <input type="text" size="20" name="item"/> <p>
				<input type="submit" value="Search"/>
			</form>
			
			<%
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
				<tr>
					<form action="product.jsp" method=”POST">
						<input type="hidden" name="add" value="insert"/>
						<th><input value="" name="item_sku" size="15"/></th>
						<th><input value="" name="item_name" size="15"/></th>
						<th><input value="" name="item_price" size="15"/></th>
						<th><input value="" name="item_cat" size="15"/></th>
						<th><input type="submit" value="Insert"/></th>
					</form>
				</tr>
				<%-- Iterate over the ResultSet --%>
				<% while ( rs.next() ) { %>
					<tr>
						<td><%=rs.getString("sku")%></td>
						<td><%=rs.getString("name")%></td>
						<td><%=rs.getInt("price")%></td>
						<td><%=rs.getString("cat")%></td>
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