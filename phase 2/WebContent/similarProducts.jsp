<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Sales Analytics</title>
</head>
<body>
	<%-- Import the java.sql package --%>
	<%@ page import="java.sql.*" %>
	<%	Connection conn;
		Statement stmt;
		ResultSet rs;
		try {
			// Registering Postgresql JDBC driver
			Class.forName("org.postgresql.Driver");
			// Open a connection to the database
			conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/CSE135", "postgres", "cse135");
		
			stmt = conn.createStatement();
			rs = stmt.executeQuery("with test as " +
				"(select temp.person_name, sum(temp.dollar) dollar, temp.product_id from " +
				"(select p.person_name, sum(pc.quantity * pc.price) dollar, pc.product_id from " +
				"person p, shopping_cart s, products_in_cart pc " + 
				"where s.person_id = p.id and pc.cart_id = s.id and s.is_purchased = true " +
				"group by p.person_name, pc.product_id " + 
				"union select p.person_name, 0 as dollar, pr.id " +
				"from person p, product pr " +
				"order by person_name) temp " +
				"group by temp.person_name, temp.product_id) " +
				"select (sum(x.dollar* y.dollar)/ " +
				"(case when (sqrt(sum(x.dollar*x.dollar))*sqrt(sum(y.dollar*y.dollar))) = 0 then CAST('1.79E+308' AS float) " +
				"else (sqrt(sum(x.dollar*x.dollar))*sqrt(sum(y.dollar*y.dollar))) end )) cosine_thing, " +
				"x.product_id p1, y.product_id p2 " +
				"from test x, test y	where x.product_id < y.product_id and x.person_name = y.person_name " +
				"group by p1, p2	order by cosine_thing desc, p1, p2 limit 100");
			%>
			<table>
				<tr>
				<th>Cosine</th>
				<th>Product 1 ID</th>
				<th>Product 2 ID</th>
				</tr>
				<%
				while (rs.next()) {
					%>
					<tr>
						<td><%=rs.getDouble("cosine_thing")%></td>
						<td><%=rs.getInt("p1")%></td>
						<td><%=rs.getInt("p2")%></td>
					</tr>
					
					<%
				}
			%></table><%
		
		
		
		
			// Close the ResultSet
			//rs.close();
			// Close the Statement
			//stmt.close();
			// Close the Connection
			//conn.close();
		} catch (SQLException e) {
			%><%= e %><%
		}%>
</body>
</html>