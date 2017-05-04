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
				
				session.setAttribute("category", category);
				session.setAttribute("item", item);
				
				Connection conn;
				Statement stmt;
				ResultSet rs;
				PreparedStatement pstmt;
				ResultSet rscat;
				try {
					// Registering Postgresql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost:5432/CSE135_DB",
					"postgres", "cse135");
					
				String action = request.getParameter("action");
				if (action != null && action.equals("insert")) {
					try {
						pstmt = conn.prepareStatement("INSERT INTO product VALUES (?, ?, ?, ?)");
						pstmt.setString(1, request.getParameter("item_sku"));
						pstmt.setString(2, request.getParameter("item_name"));
						pstmt.setInt(3, Integer.parseInt(request.getParameter("item_price")));
						pstmt.setString(4, request.getParameter("item_cat"));
						pstmt.executeUpdate();
					}
					catch (Exception e) { %>
						<h1>Failure to insert new product.</h1>
					<% }
				}
				if (action != null && action.equals("delete")) {
					try {
						pstmt = conn.prepareStatement("DELETE FROM product WHERE sku = ?");
						pstmt.setString(1, request.getParameter("delete_sku"));
						pstmt.executeUpdate();
					}
					catch (Exception e) { %>
						<h1>Failure to delete product.</h1>
					<% }					
				}
				if (action != null && action.equals("update")) {
					try {
						pstmt = conn.prepareStatement("UPDATE product SET sku = ?, name = ?, price = ?, cat = ? WHERE sku = ?");
						pstmt.setString(1, request.getParameter("item_sku"));
						pstmt.setString(2, request.getParameter("item_name"));
						pstmt.setInt(3, Integer.parseInt(request.getParameter("item_price")));
						pstmt.setString(4, request.getParameter("item_cat"));
						pstmt.setString(5,	request.getParameter("update_sku"));
						pstmt.executeUpdate();
					}
					catch (Exception e) { %>
						<h1>Failure to update product.</h1>
					<% }	
				}

				// Create the statement
				stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT * FROM category");
				rscat = conn.createStatement().executeQuery("SELECT name FROM category");
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
					<form action="product.jsp" method="POST">
						<input type="hidden" name="action" value="insert"/>
						<td><input value="" name="item_sku" /></td>
						<td><input value="" name="item_name" /></td>
						<td><input value="" name="item_price" /></td>
						<td><select name="item_cat">
							<% while (rscat.next() ) { %>
								<option value="<%=rscat.getString("name")%>"><%=rscat.getString("name")%></option>
							<% } %>
						</select></td>
						<td><input type="submit" value="Insert"/></td>
					</form>
				</tr>
				<%-- Iterate over the ResultSet --%>
				<% while ( rs.next() ) { %>
					<% rscat = conn.createStatement().executeQuery("SELECT name FROM category"); %>
					<tr>
						<form action="product.jsp" method="POST">
							<input type="hidden" name="action" value="update"/>
							<input type="hidden" name="update_sku" value="<%=rs.getString("sku")%>"/>
							<td><input value="<%=rs.getString("sku")%>" name="item_sku"/></td>
							<td><input value="<%=rs.getString("name")%>" name="item_name"/></td>
							<td><input value="<%=rs.getInt("price")%>" name="item_price"/></td>
							<td><select name="item_cat">
								<% while (rscat.next() ) { 
									if (rs.getString("cat").equals(rscat.getString("name"))) { %>
										<option value="<%=rscat.getString("name")%>" selected><%=rscat.getString("name")%></option>
									<% }
									else { %>
										<option value="<%=rscat.getString("name")%>"><%=rscat.getString("name")%></option>
									<% }
								} %>
							</select></td>
							<td><input type="submit" value="Update"></td>
						</form>
						
						<form action="product.jsp" method="POST">
							<input type="hidden" name="action" value="delete"/>
							<input type="hidden" value="<%=rs.getString("sku")%>" name="delete_sku"/>
							<td><input type="submit" value="Delete"/></td>
						</form>
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